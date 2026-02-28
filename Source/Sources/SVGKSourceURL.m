#import "SVGKSourceURL.h"
#import "SVGKDefine_Private.h"

@implementation SVGKSourceURL

-(NSString *)keyForAppleDictionaries
{
	return [self.URL absoluteString];
}

+ (SVGKSource*)sourceFromURL:(NSURL*)u {
	NSInputStream* stream = [self internalCreateInputStreamFromURL:u];
    if (!stream) {
        return nil;
    }
	
	SVGKSourceURL* s = [[SVGKSourceURL alloc] initWithInputSteam:stream];
	s.URL = u;
	
	return s;
}

+(nullable NSInputStream*) internalCreateInputStreamFromURL:(nullable NSURL*) u
{
    if (!u) {
        return nil;
    }
	NSInputStream* stream = [NSInputStream inputStreamWithURL:u];
	
	if( stream == nil )
	{
		/* Thanks, Apple, for not implementing your own method.
		 c.f. http://stackoverflow.com/questions/20571069/i-cannot-initialize-a-nsinputstream

		 NB: current Apple docs don't seem to mention this - certainly not in the inputStreamWithURL: method?

		 Use NSURLSession instead of NSData to avoid synchronous URL loading on the main thread. */
		__block NSData *tempData = nil;
		__block NSError *errorWithNSData = nil;
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

		NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:u completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			tempData = data;
			errorWithNSData = error;
			dispatch_semaphore_signal(semaphore);
		}];
		[task resume];
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

		if( tempData == nil )
		{
            SVGKitLogError(@"Error loading from URL '%@'. Error = %@", u, errorWithNSData);
		}
		else
			stream = [[NSInputStream alloc] initWithData:tempData];
	}
	//DO NOT DO THIS: let the parser do it at last possible moment (Apple has threading problems otherwise!) [stream open];
	
	return stream;
}

-(id)copyWithZone:(NSZone *)zone
{
	id copy = [super copyWithZone:zone];
	
	if( copy )
	{	
		/** clone bits */
		[copy setURL:[self.URL copy]];
		
		/** Finally, manually intialize the input stream, as required by super class */
		[copy setStream:[[self class] internalCreateInputStreamFromURL:((SVGKSourceURL*)copy).URL]];
	}
	
	return copy;
}

- (SVGKSource *)sourceFromRelativePath:(NSString *)path {
	NSURL *url = [NSURL URLWithString:path relativeToURL:self.URL];
	return [SVGKSourceURL sourceFromURL:url];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[SVGKSource: URL = \"%@\"]", self.URL ];
}


@end
