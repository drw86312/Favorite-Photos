//
//  ViewController.m
//  Favorite Photos
//
//  Created by David Warner on 6/2/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ViewController.h"
#import "Photo.h"
#import "PhotoCell.h"

@interface ViewController () <UICollectionViewDataSource ,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property NSMutableArray *photosArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *searchInput;
@property (weak, nonatomic) IBOutlet UILabel *imagesToShow;
@property (weak, nonatomic) IBOutlet UIStepper *stepperOutlet;

@end

@implementation ViewController

- (void)viewDidLoad
{
    self.imagesToShow.text = @"10";
    self.stepperOutlet.value = 10.0;
    self.stepperOutlet.stepValue = 5.0;

    [super viewDidLoad];
    self.photosArray = [[NSMutableArray alloc] init];

}
- (IBAction)onSearchButtonPressed:(id)sender
{
    [self.photosArray removeAllObjects];
    NSString *stringFromSearch = self.searchInput.text;
    [self getPhotosArray:stringFromSearch imagesToShow:self.imagesToShow.text];
    [self.searchInput resignFirstResponder];
}

- (IBAction)incrementSearchResults:(id)sender
{
    self.stepperOutlet.maximumValue = 50.0;
    self.stepperOutlet.minimumValue = 0.0;
    self.imagesToShow.text = [NSString stringWithFormat:@"%.0f", self.stepperOutlet.value];
    NSLog(@"%f", self.stepperOutlet.value);


}


-(void)getPhotosArray:(NSString *)searchTerm imagesToShow:(NSString *)imagesToShow
{
    {
        NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=467efe39db0425dcccde0a74c2a7e8a9&tags=%@&per_page=%@&format=json&nojsoncallback=1", searchTerm ,imagesToShow];

        NSURL* url  = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             NSDictionary *returnedResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];

             NSArray *tempArray = [[returnedResults objectForKey:@"photos"] objectForKey:@"photo"];

             for (NSDictionary *dictionary in tempArray)
             {
                 Photo *photo = [[Photo alloc] init];
                 NSString *farm = [dictionary objectForKey:@"farm"];
                 NSString *server = [dictionary objectForKey:@"server"];
                 NSString *ident = [dictionary objectForKey:@"id"];
                 NSString *secret = [dictionary objectForKey:@"secret"];

                 NSString *imageURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_m.jpg",farm, server, ident, secret];
                 NSURL *imageURL = [NSURL URLWithString:imageURLString];
                 UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                 photo.searchImage = image;
                 photo.imageCategory = [dictionary objectForKey:@"title"];
                 photo.imagePhotographer = [dictionary objectForKey:@"owner"];
                 photo.imageCategory = searchTerm;

                 [self.photosArray addObject:photo];
                 
                 [self.collectionView reloadData];
                 NSLog(@"%@", self.photosArray);
             }
         }];
    }
}

-(NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.photosArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Photo *photo = [self.photosArray objectAtIndex:indexPath.row];
    cell.imageView.image = photo.searchImage;

    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 10);
}



@end
