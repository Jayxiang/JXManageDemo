//
//  FileUtil.m
//  JXManageDemo
//
//  Created by tet-cjx on 2018/9/7.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import "FileUtil.h"

@interface FileUtil ()

@end

@implementation FileUtil

+ (NSString *)homeDirectoryPath {
    return NSHomeDirectory();
}

+ (NSString *)appDirectoryPath {
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
    return [array objectAtIndex:0];
}

+ (NSString *)documentDirectoryPath {
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [array objectAtIndex:0];
}

+ (NSString *)cachesDirectoryPath {
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [array objectAtIndex:0];
}

+ (NSString *)tmpDirectoryPath {
    return NSTemporaryDirectory();
}

+ (BOOL)directoryExist:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exist = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    
    if (isDirectory && exist) {
        return YES;
    }
    return NO;
}

+ (BOOL)fileExist:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

+ (BOOL)createDirectoryAtParentDirectory:(NSString *)parentDirectoryPath directoryName:(NSString *)directoryName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directoryPath = [NSString stringWithFormat:@"%@/%@", parentDirectoryPath, directoryName];
    return [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (BOOL)createFileAtParentDirectory:(NSString *)parentDirectoryPath fileName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", parentDirectoryPath, fileName];
    return [fileManager createFileAtPath:filePath contents:nil attributes:nil];
}

+ (BOOL)deleteDirectoryAtPath:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([self directoryExist:directoryPath]) {
        return [fileManager removeItemAtPath:directoryPath error:nil];
    }
    return NO;
}

+ (BOOL)deleteFileAtPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([self fileExist:filePath]) {
        return [fileManager removeItemAtPath:filePath error:nil];
    }
    return NO;
}

+ (NSArray *)contentsAtParentDirectory:(NSString *)parentDirectoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager contentsOfDirectoryAtPath:parentDirectoryPath error:nil];
}

+ (NSArray *)directoryNamesAtParentDirectory:(NSString *)parentDirectoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSMutableArray *directoryPaths = [[NSMutableArray alloc] init];
    for (NSString *content in [self contentsAtParentDirectory:parentDirectoryPath]) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", parentDirectoryPath, content];
        if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                [directoryPaths addObject:content];
            }
        }
    }
    return [directoryPaths copy];
}

+ (NSArray *)directoryPathsAtParentDirectory:(NSString *)parentDirectoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSMutableArray *directoryPaths = [[NSMutableArray alloc] init];
    for (NSString *content in [self contentsAtParentDirectory:parentDirectoryPath]) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", parentDirectoryPath, content];
        if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                [directoryPaths addObject:path];
            }
        }
    }
    return [directoryPaths copy];
}

+ (NSArray *)fileNamesAtParentDirectoryPath:(NSString *)parentDirectoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    for (NSString *content in [self contentsAtParentDirectory:parentDirectoryPath]) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", parentDirectoryPath, content];
        if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (!isDirectory) {
                [filePaths addObject:content];
            }
        }
    }
    return [filePaths copy];
}

+ (NSArray *)filePathsAtParentDirectoryPath:(NSString *)parentDirectoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    for (NSString *content in [self contentsAtParentDirectory:parentDirectoryPath]) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", parentDirectoryPath, content];
        if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (!isDirectory) {
                [filePaths addObject:path];
            }
        }
    }
    return [filePaths copy];
}

@end


