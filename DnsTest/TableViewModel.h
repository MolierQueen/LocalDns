//
//  TableViewModel.h
//  DnsTest
//
//  Created by Oliver on 2017/12/14.
//  Copyright © 2017年 meitu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewModel : NSObject
@property (nonatomic, copy) NSString * titleName;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) NSString * subTitle;
@end
