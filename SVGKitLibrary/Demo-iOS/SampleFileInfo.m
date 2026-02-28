#import "SampleFileInfo.h"

#import "SVGKSourceLocalFile.h"
#import "SVGKSourceURL.h"
#import "SVGKSourceString.h"

@interface SampleFileInfo ()
@property(nonatomic,strong) NSString* originalFilename;
@property(nonatomic,strong) NSURL* originalURL;
@property(nonatomic,strong) NSString* originalSVGString;
@property(nonatomic,strong) NSString* originalDataURI;
@end

@implementation SampleFileInfo

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f
{
	return [self sampleFileInfoWithFilename:f URL:nil name:f];
}

+(SampleFileInfo*) sampleFileInfoWithURL:(NSURL*) s
{
	return [self sampleFileInfoWithFilename:nil URL:s name:[s relativeString]];
}

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f URL:(NSURL*) s
{
	return [self sampleFileInfoWithFilename:f URL:s name:(f!=nil) ? f : [s relativeString]];
}

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f URL:(NSURL*) s name:(NSString*) n
{
	SampleFileInfo* value = [SampleFileInfo new];

	value.originalFilename = f;
	value.originalURL = s;

	value.name = n;

	return value;
}

+(SampleFileInfo*) sampleFileInfoWithSVGString:(NSString*) svgString name:(NSString*) name
{
	SampleFileInfo* value = [SampleFileInfo new];

	value.originalSVGString = svgString;
	value.name = name;

	return value;
}

+(SampleFileInfo*) sampleFileInfoWithDataURI:(NSString*) dataURI name:(NSString*) name
{
	SampleFileInfo* value = [SampleFileInfo new];

	value.originalDataURI = dataURI;
	value.name = name;

	return value;
}

-(NSString*) decodedSVGStringFromDataURI
{
	NSString* uri = self.originalDataURI;
	if( uri == nil )
		return nil;

	// data:image/svg+xml;base64,<data>
	NSRange base64Range = [uri rangeOfString:@";base64,"];
	if( base64Range.location != NSNotFound )
	{
		NSString* encoded = [uri substringFromIndex:NSMaxRange(base64Range)];
		NSData* data = [[NSData alloc] initWithBase64EncodedString:encoded options:NSDataBase64DecodingIgnoreUnknownCharacters];
		if( data != nil )
			return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		return nil;
	}

	// data:image/svg+xml;utf8,<percent-encoded> or data:image/svg+xml,<percent-encoded>
	NSRange utf8Range = [uri rangeOfString:@";utf8,"];
	if( utf8Range.location != NSNotFound )
	{
		NSString* encoded = [uri substringFromIndex:NSMaxRange(utf8Range)];
		return [encoded stringByRemovingPercentEncoding];
	}

	// Fallback: data:image/svg+xml,<percent-encoded>
	NSRange commaRange = [uri rangeOfString:@","];
	if( commaRange.location != NSNotFound )
	{
		NSString* encoded = [uri substringFromIndex:NSMaxRange(commaRange)];
		return [encoded stringByRemovingPercentEncoding];
	}

	return nil;
}

-(SVGKSource *)source
{
	if( self.originalFilename != nil )
		return [self sourceFromLocalFile];
	else if( self.originalDataURI != nil )
	{
		NSString* decoded = [self decodedSVGStringFromDataURI];
		if( decoded != nil )
			return [SVGKSourceString sourceFromContentsOfString:decoded];
		return nil;
	}
	else if( self.originalSVGString != nil )
		return [SVGKSourceString sourceFromContentsOfString:self.originalSVGString];
	else if( self.originalURL != nil )
		return [self sourceFromWeb];
	else
	{
//		D(false, @"Cannot return an SVGKSource; no valid filename nor url");
		return nil;
	}
}

-(SVGKSource *)sourceFromLocalFile
{
	return [SVGKSourceLocalFile internalSourceAnywhereInBundleUsingName:self.originalFilename];
}

-(SVGKSource *)sourceFromWeb
{
	return [SVGKSourceURL sourceFromURL:self.originalURL];
}

-(NSString *)savedBitmapFilename
{
	if( self.originalFilename != nil )
	{
		return [self.originalFilename stringByDeletingPathExtension];
	}
	else if( self.originalSVGString != nil || self.originalDataURI != nil )
	{
		return nil; // SVG string / Data URI samples have no pre-rendered bitmap
	}
	else if( self.originalURL != nil )
	{
		return [[self.originalURL relativeString] stringByDeletingPathExtension];
	}
	else
		return nil;
}

@end
