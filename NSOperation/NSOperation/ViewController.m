//
//  ViewController.m
//  NSOperation
//
//  Created by 田彬彬 on 2017/6/3.
//  Copyright © 2017年 田彬彬. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
        线程的生命周期
        1. 首先我们会创建一个线程的对象 并将这个对象放到内存中
        2. 然后我们开启线程，那么此时线程会被放倒内存池中，线程处于 准备被调用状态。等待CPU调度
        3. 当CPU 调度该线程  处于线程调度状态 （这里提一个多线程同时调度）
           当CPU 调度其他线程的时候 该线程处于 被调度状态
        4. 线程阻塞:调度sleep／等待线程阻塞时
        5. 线程的死亡:1.线程任务执行完成 自动死亡 2.线程异常／或者强制退出
    
     
        // 关于线程这一块,不建议用互斥锁 占内存 容易造成死锁
        互斥锁 是在一段时间内锁这线程 使其他线程不能访问 会占用大量的内存 不建议用
     
     
        线程的通讯
        1. 一个线程传递数给另一个线程
        2. 一个线程执行完任务后转到另一个线程继续执行任务
     */
    
    NSLog(@"打印当前线程%@",[NSThread currentThread]);
    
    // 1. NSThread
//    [self StepOneNSThread];
    
    // 2. GCD
//    [self SetTwoGCD];
    
    // 3.NSOperation
    [self SetNSOperation];
}



#pragma mark--------------------- NSThread
-(void)StepOneNSThread
{
    // 1. NSThread
    // NSThread 线程有三种表现形式
    // 1.1 创建对象  需要手动开启线程
    NSThread * thread = [[NSThread alloc]initWithTarget:self selector:@selector(CommonSelector1) object:@"abc"];
    [thread start];
    
    // 1.2 从主线程中分离出一个线程 不需要手动开启
    [NSThread detachNewThreadSelector:@selector(CommonSelector2) toTarget:self withObject:@"abc"];
    
    // 1.3 从后台开辟一个线程
    [self performSelectorInBackground:@selector(CommonSelector3) withObject:@"abc"];
}

-(void)CommonSelector1{
    NSLog(@"打印当前线程----CommonSelector1 = %@",[NSThread currentThread]);
}

-(void)CommonSelector2{
    NSLog(@"打印当前线程----CommonSelector2 = %@",[NSThread currentThread]);
}

-(void)CommonSelector3{
    NSLog(@"打印当前线程----CommonSelector3 = %@",[NSThread currentThread]);
}


#pragma MARK-------------------- GCD
-(void)SetTwoGCD{

    /*
         GCD 纯C 语言
         任务： 1. 同步 2.异步。 同步和异步的区别就在于是否具有开启线程的能力
         队列： 1. 串行 2.并行
     
     
     */

    //2. 并发队列
//        [self GCDAsync];

    
    /*
       3. 自定义并发队列
        1> sync 中  不会开启新的线程。任务是依次进行的
        2> async 中 会开启新的线程。任务是并发的
     
     */
//     [self GCDSync];
//     [self AddAsyncCurretn];
    
    /*   4  在全局队列中添加同步任务
          1> 任务是依次进行的。不会开启新的线程
         4. 在全局队列中添加异步任务
          2> 任务是并发的 会开启新的线程
     */
//    [self AddCuttentGloable];
//    
//    [self AddCuttentGloableAsync];

    
    /*  5. 串行队列中添加同步任务
           1> 不会开启新的线程 任务是逐次运行的
           串行队列中添加异步任务
     
     
     
     
     */
    
//    [self AddChuanSync];
    [self AddChuanASync];
    
    
    /**
        1. dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
           1.1> 串行队列不论是在sync 还是 async 中 执行任务  任务是依次进行的  但是在async 开启了新的线程
     
        2. dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
           2.1> 并行队列在sync 中不回开启新的线程 在 async 中会开启新的线程
     
        3. dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
           3.1> 全局队列在sync 中不会开启新的线程 在 async 中会开启新的线程
     
        4. 在async 中 如果 dispatch_get_main_queue 与 dispatch_get_global_queue 同时存在
           4.1> 执行的先后顺序是 先执行 dispatch_get_global_queue 然后执行 dispatch_get_main_queue
     
        5. 在dispatch_get_main_queue 添加sync 任务会造成死锁 
           在dispatch_get_main_queue 添加async 任务不会造成卡死。不会开启新的线程 任务是逐次完成的
     
     */
    
    
}


-(void)GCDSync
{
    
    /*
        并发队列加上同步任务。没有开启新的线程  任务是逐个执行的
     */
    
    // 并发队列
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--1--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--2--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--3--%@",[NSThread currentThread]);
        }
        
    });
}


-(void)GCDAsync
{

    dispatch_async(dispatch_get_main_queue(), ^{
       
        NSLog(@"在主队列中执行任务时不会开启新的线程的");
        
    });
    

    // dispatch_get_global_queue 队列的优先级  DISPATCH_QUEUE_PRIORITY_HIGH  高中低
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        
        for (int i = 0; i<3; i++) {
            
            NSLog(@"--5--%@",[NSThread currentThread]);
        }
    });
    
    
    // dispatch_get_global_queue 队列的优先级  DISPATCH_QUEUE_PRIORITY_HIGH  高中低
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
      
        for (int i = 0; i<3; i++) {
            
            NSLog(@"--4--%@",[NSThread currentThread]);
        }
    });
    
    

}


-(void)AddAsyncCurretn
{

    // 并发队列
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--6--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--7--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--8--%@",[NSThread currentThread]);
        }
        
    });
    
}


-(void)AddCuttentGloable
{

    // 全局队列中添加同步任务
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--10--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--11--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--12--%@",[NSThread currentThread]);
        }
        
    });

}


-(void)AddCuttentGloableAsync
{
    
    // 全局队列中添加同步任务
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--13--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--14--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--15--%@",[NSThread currentThread]);
        }
        
    });
    
}

-(void)AddChuanSync
{
    // 串行队列
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--15--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--16--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--17--%@",[NSThread currentThread]);
        }
        
    });
}

-(void)AddChuanASync{

    // 串行队列
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--18--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--19--%@",[NSThread currentThread]);
        }
        
    });
    
    dispatch_async(queue, ^{
        
        for (int i = 0; i<5; i++) {
            
            NSLog(@"--20--%@",[NSThread currentThread]);
        }
        
    });


}


#pragma mark----------------- NSOperation
-(void)SetNSOperation
{
    //1. 第一种
//    NSOperation * option = [[NSOperation alloc]init];
    
//    [self invocationooeration];
    
    [self blockOperation];
    
    
    

}


// invocationooeration
-(void)invocationooeration
{
    NSInvocationOperation * ip  = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operationSelector) object:nil];
    
    
    
    [ip start];
    
}

-(void)operationSelector
{
    NSLog(@"打印当前线程-----%@", [NSThread currentThread]);
}

// blockOperation
-(void)blockOperation
{
    // 在主线程中完成
    NSBlockOperation * bp = [NSBlockOperation blockOperationWithBlock:^{
        
         NSLog(@"打印当前线程-----%@", [NSThread currentThread]);
        
    }];
    
    // 添加其他任务  在子线程中完成
    [bp addExecutionBlock:^{
       
         NSLog(@"打印当前线程2-----%@", [NSThread currentThread]);
        
    }];
    
    
    [bp start];
}


// 自定义
-(void)CustomOperaion
{
    NSLog(@"我不想写了吗，做项目根本用不到，如果面试官问你，你问他 你用过嘛, 这谁用谁sb。有病啊 孩子定义。你咋不上天呢 不写了 没什么鸡吧用");
}



@end
