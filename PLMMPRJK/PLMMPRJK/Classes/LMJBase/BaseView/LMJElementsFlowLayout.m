//
//  LMJElementsFlowLayout.m
//
//  Created by apple on 17/4/19.
//  Copyright © 2017年 NJHu. All rights reserved.
//
#import "LMJElementsFlowLayout.h"


static const CGFloat LMJ_XMargin_ = 10;
static const CGFloat LMJ_YMargin_ = 10;
static const UIEdgeInsets LMJ_EdgeInsets_ = {20, 10, 10, 10};

@interface LMJElementsFlowLayout()

/** 所有的cell的attrbts */
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *lmj_AtrbsArray;

/** 每一列的最后的高度 */
/** <#digest#> */
@property (assign, nonatomic) CGRect lmj_LastAtrbsFrame;


- (CGFloat)xMargin;

- (CGFloat)yMargin;

- (UIEdgeInsets)edgeInsets;


- (CGRect)maxHeightFrame;


@end

@implementation LMJElementsFlowLayout



/**
 *  刷新布局的时候回重新调用
 */
- (void)prepareLayout
{
    [super prepareLayout];
    
    //如果重新刷新就需要移除之前存储的高度
    //复赋值以顶部的高度, 并且根据列数
    self.lmj_LastAtrbsFrame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.edgeInsets.top);
    
    
    
    // 移除以前计算的cells的attrbs
    [self.lmj_AtrbsArray removeAllObjects];
    
    // 并且重新计算, 每个cell对应的atrbs, 保存到数组
    for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++)
    {
        [self.lmj_AtrbsArray addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
    }
    
    
    
}


/**
 *在这里边所处每个cell对应的位置和大小
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *atrbs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 原来的
    //    CGFloat w = 1.0 * (self.collectionView.frame.size.width - self.edgeInsets.left - self.edgeInsets.right - self.xMargin * (self.columns - 1)) / self.columns;
    
    CGFloat w = [self.delegate waterflowLayout:self sizeForItemAtIndexPath:indexPath].width;
    w = MIN(w, [UIScreen mainScreen].bounds.size.width);
    
    // 高度由外界决定, 外界必须实现这个方法
    CGFloat h = [self.delegate waterflowLayout:self sizeForItemAtIndexPath:indexPath].height;
    
    // 拿到最后的高度最小的那一列, 假设第0列最小
    CGFloat rightLeftWidth = self.collectionView.frame.size.width - CGRectGetMaxX(self.lmj_LastAtrbsFrame) - self.xMargin - self.edgeInsets.right;
    
    CGFloat x = 0;
    CGFloat y = 0;
    
    
    if (w > [UIScreen mainScreen].bounds.size.width - self.edgeInsets.left - self.edgeInsets.right) {
        
        x = (self.collectionView.frame.size.width - w) * 0.5;
        y = CGRectGetMaxY(self.lmj_LastAtrbsFrame) + self.yMargin;
        
    }else if (rightLeftWidth >= w) {
        
        x = CGRectGetMaxX(self.lmj_LastAtrbsFrame) + self.xMargin;
        y = self.lmj_LastAtrbsFrame.origin.y;
        
    }else
    {
        x = self.edgeInsets.left;
        y = CGRectGetMaxY(self.lmj_LastAtrbsFrame) + self.yMargin;
    }
    
    if (CGRectGetMaxY(self.lmj_LastAtrbsFrame) == self.edgeInsets.top) {
        
        y = self.edgeInsets.top;
    }
    
    // 赋值frame
    atrbs.frame = CGRectMake(x, y, w, h);
    
    // 覆盖添加完后那一列;的最新高度
    self.lmj_LastAtrbsFrame = atrbs.frame;
    
    return atrbs;
}


- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.lmj_AtrbsArray;
}


- (CGRect)maxHeightFrame
{
    __block CGRect maxHeightFrame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.edgeInsets.top);
    
    
    [self.lmj_AtrbsArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (CGRectGetMaxY(obj.frame) > CGRectGetMaxY(maxHeightFrame)) {
            
            maxHeightFrame = obj.frame;
            
        }
        
    }];
    
    return maxHeightFrame;
}



- (CGSize)collectionViewContentSize
{
    
    return CGSizeMake(self.collectionView.frame.size.width, CGRectGetMaxY(self.maxHeightFrame) + self.edgeInsets.bottom);
}


- (NSMutableArray *)lmj_AtrbsArray
{
    if(_lmj_AtrbsArray == nil)
    {
        _lmj_AtrbsArray = [NSMutableArray array];
    }
    return _lmj_AtrbsArray;
}


- (CGFloat)xMargin
{
    if([self.delegate respondsToSelector:@selector(waterflowLayouOftMarginBetweenColumns:)])
    {
        return [self.delegate waterflowLayouOftMarginBetweenColumns:self];
    }
    else
    {
        return LMJ_XMargin_;
    }
}

- (CGFloat)yMargin
{
    if([self.delegate respondsToSelector:@selector(waterflowLayoutOfMarginBetweenLines:)])
    {
        return [self.delegate waterflowLayoutOfMarginBetweenLines:self];
    }else
    {
        return LMJ_YMargin_;
    }
}

- (UIEdgeInsets)edgeInsets
{
    if([self.delegate respondsToSelector:@selector(waterflowLayoutOfEdgeInsets:)])
    {
        return [self.delegate waterflowLayoutOfEdgeInsets:self];
    }
    else
    {
        return LMJ_EdgeInsets_;
    }
}

@end