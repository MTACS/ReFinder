//
//  ReFinder.h
//  ReFinder
//
//  Created by MTAC on 12/26/21.
//
//

@import AppKit;

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ZKSwizzle.h"
// #import "ReFinderPreferencesController.h"
#include <dlfcn.h>

struct OpaqueNodeRef;

struct TFENode {
    struct OpaqueNodeRef *x0;
};

@interface NSView (ReFinder)
- (NSViewController *)parentViewController;
@end

@interface BRContainer : NSObject
@property (readonly, nonatomic) NSURL *url;
- (id)_containerRepositoryURL;
@end

@interface OSDManager : NSObject
+ (id)sharedManager;
@property(retain) NSXPCConnection *connection;
- (void)showFullScreenImage:(long long)arg1 onDisplayID:(unsigned int)arg2 priority:(unsigned int)arg3 msecToAnimate:(unsigned int)arg4;
- (void)fadeClassicImageOnDisplay:(unsigned int)arg1;
- (void)showImageAtPath:(id)arg1 onDisplayID:(unsigned int)arg2 priority:(unsigned int)arg3 msecUntilFade:(unsigned int)arg4 withText:(id)arg5;
- (void)showImage:(long long)arg1 onDisplayID:(unsigned int)arg2 priority:(unsigned int)arg3 msecUntilFade:(unsigned int)arg4 filledChiclets:(unsigned int)arg5 totalChiclets:(unsigned int)arg6 locked:(BOOL)arg7;
- (void)showImage:(long long)arg1 onDisplayID:(unsigned int)arg2 priority:(unsigned int)arg3 msecUntilFade:(unsigned int)arg4 withText:(id)arg5;
- (void)showImage:(long long)arg1 onDisplayID:(unsigned int)arg2 priority:(unsigned int)arg3 msecUntilFade:(unsigned int)arg4;
@end

@interface FPItemManager : NSObject
+ (id)defaultManager;
- (void)fetchURLForItem:(id)item completionHandler:(id)handler;
- (void)fetchURLForItem:(id)item creatingPlaceholderIfMissing:(_Bool)missing completionHandler:(id /* block */)handler;
@end

@interface FPItem : NSObject
@property (retain, nonatomic) NSURL *fileURL;
@property (copy, nonatomic) NSString *fileSystemFilename;
@property (retain, nonatomic) NSURL *detachedRootLogicalURL;
@end

@interface FINode : NSObject
@property (readonly, copy, nonatomic) NSURL *fileURL;
@property (readonly, nonatomic) NSArray *itemDecorations;
@property (readonly, copy, nonatomic) FPItem *fpItem;
@property (readonly, nonatomic) FINode *parent;
@property (readonly, copy, nonatomic) BRContainer *brContainer;
@property (readonly, nonatomic) _Bool isTopLevelSharedItem;
+ (id)_allRootInstances;
+ (id)nodeFromNodeRef:(struct OpaqueNodeRef *)ref;
- (id)debugDescription;
- (id)longDescription;
- (id)previewItemURL;
- (id)launchURL;
- (id)fileParent;
@end

@interface FIDSNode : FINode
- (NSURL *)previewItemURL;
- (NSString *)previewItemTitle;
@end

@interface RFVisualEffectView : NSVisualEffectView
@end

@interface NSTitlebarView : NSView
- (void)setMaterial:(long long)material;
@end

@interface TView : NSView
- (void)setWantsLayer:(BOOL)arg1;
@end

@interface TUpdateLayerView: NSView
@property (retain, nonatomic) NSColor *backgroundColor;
@end

@interface TScrollView : NSScrollView
@end

@interface TBrowserWindow : NSWindow
@end

@interface TIconView : NSView
@property (copy, nonatomic) NSString *titleStr;
@end

@interface TTitleBubbleView : NSView
@property (retain, nonatomic) NSColor *superViewsBackgroundColor;
- (CGRect)titleFrame;
- (CGRect)bubbleFrame;
@end

@interface TDesktopIconView : NSView {
    TTitleBubbleView *_titleBubbleView;
}
@end

@interface TCollectionViewItem : NSCollectionViewItem
- (struct TFENode)node;
@end

@interface TIconCollectionView : NSCollectionView
@property (copy) NSIndexSet *selectionIndexes;
@property (copy) NSSet *selectionIndexPaths;
- (id)_firstSelectionIndexPath;
- (struct TFENode)nodeForIndexPath:(id)path;
- (struct TFENode *)nodeForIconView:(id)view;
- (id)iconViewForIndexPath:(id)path;
@end

@interface TListView : NSOutlineView
@end

@interface TColumnView : NSBrowser
- (id)_rootItem;
@end

@interface TListNameFieldCell : NSTextFieldCell
@end

@interface TQLPreviewWindowController : NSObject
@end

@interface TBrowserViewController : NSViewController
@property (weak, nonatomic) NSView *browserView;
- (struct TFENode *)target;
- (struct TFENode *)browserRoot;
- (const void *)targetPath;
- (const void *)resolvedTargetPath;
- (struct TFENode *)focusNode;
- (id)contextMenuItemTarget;
@end

@interface TSidebarSplitViewController : NSSplitViewController
@property (readonly, nonatomic) NSSplitViewItem *sidebarSplitViewItem;
@end

@interface TIconCollectionViewController : TBrowserViewController
@end

@interface TIconOrGalleryCollectionViewController : NSViewController
- (struct TFENode *)nodeBeingEdited;
- (struct TFENode)nodeClickedOnMouseDown;
@end

@interface TDesktopView : NSView
- (struct TFENode)nodeAtPoint:(const CGPoint *)point;
- (id)desktopIconAtPoint:(const CGPoint *)point;
@end

@interface _NSSplitViewItemViewWrapper : NSView
@property (retain) NSSplitViewItem *splitViewItem;
@end

@interface NSMenuItem (ReFinder)
@property (readonly, getter=isSeparatorItem) BOOL separatorItem;
- (void)_unconfigureAsSeparatorItem;
- (void)_configureAsSeparatorItem;
@end

@interface TContextMenuItem : NSMenuItem
@end

@interface NSSplitDividerView : NSView
@property (copy) NSColor *backgroundColor;
@property long long style;
@end

@interface NSVibrantSplitDividerView : NSView
- (NSAppearance *)_preferredAppearance;
@end

@interface NSAppearance (ReFinder)
+ (id)_applicationAppearance;
+ (id)_syrahAppearance;
+ (id)_aquaAppearance;
+ (id)_darkAquaAppearance;
+ (id)_fauxVibrantDarkAppearance;
+ (id)_fauxVibrantLightAppearance;
+ (id)_contentBackgroundAppearance;
+ (id)_vibrantDarkAppearance;
+ (id)_vibrantLightAppearance;
@end

@interface QLPreviewReply : NSObject
@property (retain) UTType *contentType;
@end

@interface UTType : NSObject
@property (readonly) NSString *preferredFilenameExtension;
+ (id)typeWithFilenameExtension:(id)extension;
+ (id)_typeOfItemAtFileURL:(NSURL *)url error:(id *)error;
@end

