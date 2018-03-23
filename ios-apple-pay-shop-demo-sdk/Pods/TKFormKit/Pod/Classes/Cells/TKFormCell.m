//  Created by Leandro Souza 9/10/14.
//  Copyright (c) 2017 Taras Kalapun. All rights reserved.
//

#import "TKFormCell.h"
#import "TKFormStyle.h"
#import "TKFormRow.h"

@implementation TKFormCell

- (instancetype)initWithRow:(TKFormRow *)row {
    return [self initWithReuseIdentifier:nil row:row];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier row:(TKFormRow *)row {
    TKFormCell *cell = nil;
    cell = [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    cell.row = row;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)awakeFromNib {
    [self configure];
}


- (id)value {
    return self.row.value;
}

- (void)setValue:(id)value {
    self.row.value = value;
}

- (BOOL)disabled {
    return self.row.disabled;
}


- (void)configure {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    self.textLabel.font = [TKFormStyle textFont];
    
    self.detailTextLabel.textColor = [TKFormStyle darkGreyColor];
}

- (void)update {
    self.textLabel.text = self.row.title;
    self.textLabel.textColor  = self.disabled ? [TKFormStyle disabledTextColor] : [TKFormStyle textColor];
    
    if (self.row.hasImage && self.row.image.length > 0) {
        NSString *path = (self.row.imagePath.length > 0) ? [self.row.imagePath stringByAppendingPathComponent:self.row.image] : self.row.image;
        UIImage *image = [UIImage imageNamed:path];
        if (!image) {
            NSLog(@"Image not found: %@", image);
        }
        self.imageView.image = image;
        
    }
}

- (void)doneAcessoryButtonPressed:(id)sender {
    [self resignFirstResponder];
}

- (UIView *)doneInputAccessoryView {
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAcessoryButtonPressed:)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setItems:@[flexibleSpace, btn]];
    [toolbar sizeToFit];
    
    return toolbar;
}

- (TKFormViewController *)formViewController {
    id responder = self;
    while (responder){
        if ([responder isKindOfClass:[UIViewController class]]){
            return responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

- (void)formCellDidSelectedWithFormController:(TKFormViewController *)controller {}

- (void)controlValueChanged:(id)sender {}

@end
