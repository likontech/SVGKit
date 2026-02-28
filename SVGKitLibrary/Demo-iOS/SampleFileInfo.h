#import <Foundation/Foundation.h>

#import "SVGKSource.h"

@interface SampleFileInfo : NSObject

@property(nonatomic,strong) NSString* author, * licenseType, * name;
@property(nonatomic, assign) BOOL requiresLayeredImageView;
@property(weak, nonatomic,readonly) SVGKSource* source;

-(SVGKSource*) sourceFromWeb;
-(SVGKSource*) sourceFromLocalFile;

-(NSString*) savedBitmapFilename;

+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f;
+(SampleFileInfo*) sampleFileInfoWithURL:(NSURL*) s;
+(SampleFileInfo*) sampleFileInfoWithFilename:(NSString*) f URL:(NSURL*) s;
+(SampleFileInfo*) sampleFileInfoWithSVGString:(NSString*) svgString name:(NSString*) name;
+(SampleFileInfo*) sampleFileInfoWithDataURI:(NSString*) dataURI name:(NSString*) name;

@end
