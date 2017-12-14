//
//  ViewController.m
//  DnsTest
//
//  Created by Oliver on 2017/12/14.
//  Copyright © 2017年 meitu. All rights reserved.
//

#import "ViewController.h"
#import "TableViewModel.h"


#import <resolv.h>
#include <arpa/inet.h>

#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <stdio.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong)NSArray * dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    TableViewModel * model1 = [[TableViewModel alloc] init];
    model1.titleName = @"handle1";
    model1.selector = @selector(localDNS1);
    model1.subTitle = @"int res_query(char *domain_name, int class, int type, char *answer_buffer, int answer_buffer_length)";
    TableViewModel * model2 = [[TableViewModel alloc] init];
    model2.titleName = @"Auto1";
    model2.selector = @selector(autoDNS1);
    model2.subTitle = @"int res_query(char *domain_name, int class, int type, char *answer_buffer, int answer_buffer_length)";
    
    TableViewModel * model3 = [[TableViewModel alloc] init];
    model3.titleName = @"handle2";
    model3.selector = @selector(localDNS2);
    model3.subTitle = @"struct hostent *gethostbyname(const char *hostName);";

    TableViewModel * model4 = [[TableViewModel alloc] init];
    model4.titleName = @"Auto2";
    model4.selector = @selector(autoDNS2);
    model4.subTitle = @"struct hostent *gethostbyname(const char *hostName);";
    
    TableViewModel * model5 = [[TableViewModel alloc] init];
    model5.titleName = @"handle3";
    model5.selector = @selector(localDNS3);
    model5.subTitle = @"Boolean CFHostStartInfoResolution (CFHostRef theHost, CFHostInfoType info, CFStreamError *error);";

    TableViewModel * model6 = [[TableViewModel alloc] init];
    model6.titleName = @"Auto3";
    model6.selector = @selector(autoDNS3);
    model6.subTitle = @"Boolean CFHostStartInfoResolution (CFHostRef theHost, CFHostInfoType info, CFStreamError *error);";
    
    self.dataArr = [NSArray arrayWithObjects:model1, model2, model3, model4, model5, model6, nil];
}

- (void)localDNS1 {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();

    unsigned char auResult[512];
    int nBytesRead = 0;
    
    nBytesRead = res_query("www.meitu.com", ns_c_in, ns_t_a, auResult, sizeof(auResult));
    
    ns_msg handle;
    ns_initparse(auResult, nBytesRead, &handle);
    
    NSMutableArray *ipList = nil;
    int msg_count = ns_msg_count(handle, ns_s_an);
    if (msg_count > 0) {
        ipList = [[NSMutableArray alloc] initWithCapacity:msg_count];
        for(int rrnum = 0; rrnum < msg_count; rrnum++) {
            ns_rr rr;
            if(ns_parserr(&handle, ns_s_an, rrnum, &rr) == 0) {
                char ip1[16];
                strcpy(ip1, inet_ntoa(*(struct in_addr *)ns_rr_rdata(rr)));
                NSString *ipString = [[NSString alloc] initWithCString:ip1 encoding:NSASCIIStringEncoding];
                if (![ipString isEqualToString:@""]) {
                    
                    //将提取到的IP地址放到数组中
                    [ipList addObject:ipString];
                }
            }
        }
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        NSLog(@"11111 === ip === %@ === time cost: %0.3fs", ipList,end - start);
    }
}
- (void)autoDNS1 {
    NSTimer * time = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(localDNS1) userInfo:nil repeats:YES];
}

- (void)localDNS2 {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    char   *ptr, **pptr;
    struct hostent *hptr;
    char   str[32];
    ptr = "www.baidu.com";
    NSMutableArray * ips = [NSMutableArray array];
    
    if((hptr = gethostbyname(ptr)) == NULL)
    {
        printf("no ips %s", ptr);
        return;
    }
    
    printf("official hostname:%s\n",hptr->h_name);
    for(pptr = hptr->h_aliases; *pptr != NULL; pptr++)
        printf(" alias hostname:%s\n",*pptr);
    
    switch(hptr->h_addrtype)
    {
        case AF_INET:
        case AF_INET6:
            for(pptr=hptr->h_addr_list; *pptr!=NULL; pptr++) {
                NSString * ipStr = [NSString stringWithCString:inet_ntop(hptr->h_addrtype, *pptr, str, sizeof(str)) encoding:NSUTF8StringEncoding];
                [ips addObject:ipStr?:@""];
            }
//                printf(" address:%s\n", inet_ntop(hptr->h_addrtype, *pptr, str, sizeof(str)));
//            printf(" first address: %s\n",inet_ntop(hptr->h_addrtype, hptr->h_addr, str, sizeof(str)));
            break;
        default:
//            printf("unknown address type\n");
            break;
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"22222 === ip === %@ === time cost: %0.3fs", ips,end - start);
    
    
}
- (void)autoDNS2 {
    NSTimer * time = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(localDNS2) userInfo:nil repeats:YES];
}

- (void)localDNS3 {

    Boolean result,bResolved;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;
    NSMutableArray * ipsArr = [[NSMutableArray alloc] init];
    CFStringRef hostNameRef = CFStringCreateWithCString(kCFAllocatorDefault, "www.meitu.com", kCFStringEncodingASCII);
    
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, hostNameRef);
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
    if (result == TRUE) {
        addresses = CFHostGetAddressing(hostRef, &result);
    }
    bResolved = result == TRUE ? true : false;
    
    if(bResolved)
    {
        struct sockaddr_in* remoteAddr;
        for(int i = 0; i < CFArrayGetCount(addresses); i++)
        {
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
            
            if(remoteAddr != NULL)
            {
                //获取IP地址
                char ip[16];
                strcpy(ip, inet_ntoa(remoteAddr->sin_addr));
                NSString * ipStr = [NSString stringWithCString:ip encoding:NSUTF8StringEncoding];
                [ipsArr addObject:ipStr];
            }
        }
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"33333 === ip === %@ === time cost: %0.3fs", ipsArr,end - start);
    CFRelease(hostNameRef);
    CFRelease(hostRef);
}
- (void)autoDNS3 {
    NSTimer * time = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(localDNS3) userInfo:nil repeats:YES];
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = ((TableViewModel *)[self.dataArr objectAtIndex:indexPath.row]).titleName;
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    [self performSelector:((TableViewModel *)[self.dataArr objectAtIndex:indexPath.row]).selector];
    if ([self respondsToSelector:((TableViewModel *)[self.dataArr objectAtIndex:indexPath.row]).selector]) {
        IMP imp = [self methodForSelector:((TableViewModel *)[self.dataArr objectAtIndex:indexPath.row]).selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, ((TableViewModel *)[self.dataArr objectAtIndex:indexPath.row]).selector);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
