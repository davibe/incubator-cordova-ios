/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVCordovaView.h"

@class WebView;
@class WebFrame;
@class WebScriptCallFrame;

@implementation CDVCordovaView


- (void)loadRequest:(NSURLRequest *)request
{
	[super loadRequest:request];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/


// Debugging support.
// It makes use of a PRIVATE api so it will not get approved to the appstore.
// It's useful while developing though

- (void)webView:(id)sender
didClearWindowObject:(id)windowObject
            forFrame:(id)frame {
    if (!sourceMap) {
        sourceMap = [[[NSMutableDictionary alloc] init] retain];
    }
    [sender setScriptDebugDelegate:self];
}

- (void)webView:(id)webView
 didParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
       sourceId:(int)sid
    forWebFrame:(WebFrame *)webFrame
{
    if (!url) return;
    [sourceMap setObject:[NSString stringWithFormat:@"%@", url] forKey:[NSString stringWithFormat:@"%d", sid]];
}

- (void)webView:(id)webView
failedToParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
      withError:(NSError *)error
    forWebFrame:(WebFrame *)webFrame
{
    NSLog(@"WEBVIEW failedToParseSource:\n"
          "  url=%@\n"
          "  line=%d\n"
          "  error=%@\n"
          "  source=%@", url, lineNumber, error, source);
}

- (void)webView:(id)webView
exceptionWasRaised:(id)frame
     hasHandler:(BOOL)hasHandler
       sourceId:(int)sid
           line:(int)lineno
    forWebFrame:(WebFrame *)webFrame
{
    if (hasHandler) return;
    
    NSString *url = [NSString stringWithFormat:@"%@", [sourceMap objectForKey:[NSString stringWithFormat:@"%d", sid]]];
    
    NSLog(@"WEBVIEW Exception:\n"
          "  sid=%d\n"
          "  url=%@\n"
          "  line=%d\n"
          "  function=%@\n"
          "  caller=%@\n"
          "  exception=%@", sid, url, lineno, [frame functionName], [frame caller], [[frame exception] stringRepresentation]);
}


- (void)dealloc {
    [super dealloc];
}


@end
