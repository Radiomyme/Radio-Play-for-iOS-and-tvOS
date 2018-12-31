//
//  XMLUtilities.h
//  Radio Play by Radiomyme
//


#import "XMLUtilities.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult);
NSArray *PerformXPathQuery(xmlDocPtr doc, NSDictionary *namespaceMappings, NSString *query);

NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult) {
	NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
	
	if(currentNode->name) {
		NSString *currentNodeContent = [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
		[resultForNode setObject:currentNodeContent forKey:@"nodeName"];
	}
	
	if(currentNode->content && currentNode->type != XML_DOCUMENT_TYPE_NODE) {
		NSString *currentNodeContent = [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];
		
		if([[resultForNode objectForKey:@"nodeName"] isEqual:@"text"] && parentResult) {
			currentNodeContent = [currentNodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			NSString *existingContent = [parentResult objectForKey:@"nodeContent"];
			NSString *newContent;
			if(existingContent) {
				newContent = [existingContent stringByAppendingString:currentNodeContent];
			} else {
				newContent = currentNodeContent;
			}
            
			[parentResult setObject:newContent forKey:@"nodeContent"];
            
			return nil;
		}
		
		[resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
	}
	
	xmlAttr *attribute = currentNode->properties;
	if(attribute) {
		NSMutableArray *attributeArray = [NSMutableArray array];
		while(attribute) {
			NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
			NSString *attributeName =
            [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
			if(attributeName) {
				[attributeDictionary setObject:attributeName forKey:@"attributeName"];
			}
			
			if(attribute->children) {
				NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary);
				if(childDictionary) {
					[attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
				}
			}
			
			if([attributeDictionary count] > 0) {
				[attributeArray addObject:attributeDictionary];
			}
			attribute = attribute->next;
		}
		
		if([attributeArray count] > 0) {
			[resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
		}
	}
    
	xmlNodePtr childNode = currentNode->children;
	if(childNode) {
		NSMutableArray *childContentArray = [NSMutableArray array];
		while(childNode) {
			NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode);
			if(childDictionary) {
				[childContentArray addObject:childDictionary];
			}
			childNode = childNode->next;
		}
		if([childContentArray count] > 0) {
			[resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
		}
	}
	
	return resultForNode;
}

NSArray *PerformXPathQuery(xmlDocPtr doc, NSDictionary *namespaceMappings, NSString *query) {
    xmlXPathContextPtr xpathCtx; 
    xmlXPathObjectPtr xpathObj; 
    
    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    if(xpathCtx == NULL) {
		NSLog(@"Unable to create XPath context.");
		return nil;
    }
    
    for(NSString *prefix in namespaceMappings) {
        xmlXPathRegisterNs(xpathCtx, (xmlChar *)[prefix UTF8String], (xmlChar *)[[namespaceMappings objectForKey:prefix] UTF8String]);
	}
    
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if(xpathObj == NULL) {
		NSLog(@"Unable to evaluate XPath.");
        
        xmlXPathFreeContext(xpathCtx);
		return nil;
    }
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if(!nodes) {
		NSLog(@"Nodes was nil.");
        
        xmlXPathFreeObject(xpathObj);
        xmlXPathFreeContext(xpathCtx);
        
		return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for(NSInteger i = 0; i < nodes->nodeNr; i++) {
		NSDictionary *nodeDictionary = DictionaryForNode(nodes->nodeTab[i], nil);
		if(nodeDictionary) {
			[resultNodes addObject:nodeDictionary];
		}
	}
    
    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx); 
    
    return resultNodes;
}

NSArray *PerformXMLXPathQuery(NSData *document, NSDictionary *namespaceMappings, NSString *query) {
    xmlDocPtr doc;
	
    /* Load XML document */
	doc = xmlReadMemory([document bytes], [document length], "", NULL, XML_PARSE_RECOVER);
	
    if(doc == NULL) {
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, namespaceMappings, query);
    xmlFreeDoc(doc); 
	
	return result;
}
