#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString *textToAnalyse = @"Sam is my senpai, and I really look up to them. Their advice and comforting words have helped me a lot. They're totally cool!";

		// This range contains the entire string, since we want to parse it completely
		NSRange stringRange = NSMakeRange(0, textToAnalyse.length);

		// Dictionary with a language map
		NSArray *language = [NSArray arrayWithObjects:@"en",nil];
		NSDictionary* languageMap = [NSDictionary dictionaryWithObject:language forKey:@"Latn"];

		[textToAnalyse enumerateLinguisticTagsInRange:stringRange scheme:NSLinguisticTagSchemeLexicalClass options:0 orthography:[NSOrthography orthographyWithDominantScript:@"Latn" languageMap:languageMap] usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
			if ([tag isEqualToString:@"Pronoun"]) 
			{
				NSLog(@"%@ is a %@", [textToAnalyse substringWithRange:tokenRange], tag);
			}
		}];
	}
}