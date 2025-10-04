//
//  ReFinder.m
//  ReFinder
//
//  Created by MTAC on 12/26/21.
//
//

#import "ReFinder.h"
#import <ImageIO/ImageIO.h>
#import <os/log.h>

@import AppKit;

NSUserDefaults *defaults;
NSMutableDictionary *finderDictionary;
NSIndexPath *browserRootPath;
NSInteger selectedListRow = 0;
static NSString *columnPath = nil;

NSVisualEffectMaterial selectedBlurMaterial(void) {
    NSInteger selectedBlurStyle = [[defaults objectForKey:@"selectedBlurStyle"] integerValue];
    return (NSVisualEffectMaterial)selectedBlurStyle;
}

void removeBackground(NSWindow *window) {
    if ([defaults boolForKey:@"useTranslucency"]) {
        if (![window isKindOfClass:NSClassFromString(@"TDesktopWindow")]) {
            [window setTitlebarAppearsTransparent:YES];
            [window setTitleVisibility:NSWindowTitleVisible];
            [window setBackgroundColor:[NSColor clearColor]];
            window.titlebarSeparatorStyle = NSTitlebarSeparatorStyleNone;
            
            if ([window isKindOfClass:NSClassFromString(@"TDesktopWindow")]) {
                [window setToolbarStyle:NSWindowToolbarStyleUnified];
            }
            
            NSVisualEffectView *effectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, window.contentView.bounds.size.width, window.contentView.bounds.size.height + 30)];
            [effectView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            [effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
            [effectView setState:NSVisualEffectStateActive];
            [effectView setMaterial:selectedBlurMaterial()];
            for (NSView *view in [window.contentView subviews]) {
                if ([view isKindOfClass:NSClassFromString(@"NSVisualEffectView")]) {
                    [view removeFromSuperview];
                }
            }
            [[window contentView] addSubview:effectView positioned:NSWindowBelow relativeTo:nil];
            
            [window.contentView setWantsLayer:YES];
            window.contentView.layer.backgroundColor = [NSColor clearColor].CGColor;
            
            for (NSView *view in window.contentView.subviews) {
                if (![view isKindOfClass:[NSImageView class]] || ![view isKindOfClass:[NSTextField class]]) {
                    [view setWantsLayer:YES];
                    view.layer.backgroundColor = [NSColor clearColor].CGColor;
                }
            }
        }
    }
}

@implementation NSView (ReFinder)
- (NSViewController *)parentViewController {
    NSResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[NSViewController class]]) {
            return (NSViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}
@end

@implementation RFVisualEffectView
- (id)init {
    return [super init];
}
- (NSInteger)tag {
    return 1000;
}
@end

ZKSwizzleInterface(rf_AboutController, TAboutWindowController, NSWindowController)
@implementation rf_AboutController
- (void)windowDidLoad {
    ZKOrig(void);
    NSTextField *field = (NSTextField *)[self.window.contentView.subviews lastObject];
    [field setStringValue:[NSString stringWithFormat:@"%@\n\nReFinder 1.3 © D.F. (MTAC)", field.stringValue]];
    removeBackground(self.window);
}
@end

ZKSwizzleInterface(rf_TApplicationController, TApplicationController, NSResponder)
@implementation rf_TApplicationController
- (id)applicationDockMenu:(id)arg1 {
    NSMenu *dockMenu = ZKOrig(id, arg1);
    
    NSMenuItem *reFinderItem = [[NSMenuItem alloc] init];
    [reFinderItem setTitle:@"ReFinder"];
    
    [dockMenu addItem:[NSMenuItem separatorItem]];
    [dockMenu addItem:reFinderItem];
    [dockMenu setSubmenu:[self reFinderMenu] forItem:reFinderItem];
    
    return dockMenu;
}
- (void)configureFinderMenu {
    ZKOrig(void);
    
    NSMenuItem *reFinderItem = [[NSMenuItem alloc] init];
    [reFinderItem setTitle:@"ReFinder"];
    
    NSMenu *mainFinderMenu = [[[[NSApp mainMenu] itemArray] firstObject] submenu];
    for (NSMenuItem *menuItem in mainFinderMenu.itemArray) {
        if ([menuItem.title isEqualToString:@"ReFinder"]) {
            [mainFinderMenu removeItem:menuItem];
        }
    }
    [mainFinderMenu addItem:[NSMenuItem separatorItem]];
    [mainFinderMenu addItem:reFinderItem];
        
    [mainFinderMenu setSubmenu:[self reFinderMenu] forItem:reFinderItem];
}
- (NSMenu *)reFinderMenu {
    NSMenu *reFinderSubMenu = [[NSMenu alloc] initWithTitle:@"ReFinder"];
    NSMenuItem *restartItem = [[NSMenuItem alloc] init];
    [restartItem setTitle:@"Restart Finder"];
    [restartItem setTarget:self];
    [restartItem setAction:@selector(restartFinder)];
    [reFinderSubMenu addItem:restartItem];
    
    NSMenuItem *restartDockItem = [[NSMenuItem alloc] init];
    [restartDockItem setTarget:self];
    [restartDockItem setAction:@selector(restartDock)];
    [restartDockItem setTitle:@"Restart Dock"];
    [reFinderSubMenu addItem:restartDockItem];
    [reFinderSubMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *toggleHiddenItem = [[NSMenuItem alloc] init];
    [toggleHiddenItem setTarget:self];
    [toggleHiddenItem setAction:@selector(toggleHidden:)];
    if ([self hiddenFilesAreShown]) {
        [toggleHiddenItem setTitle:@"Hide hidden files"];
    } else {
        [toggleHiddenItem setTitle:@"Show Hidden Files"];
    }
    [reFinderSubMenu addItem:toggleHiddenItem];
    
    NSMenuItem *toggleDesktopItem = [[NSMenuItem alloc] init];
    [toggleDesktopItem setTarget:self];
    [toggleDesktopItem setAction:@selector(toggleDesktop:)];
    if ([self desktopIconsAreShown]) {
        [toggleDesktopItem setTitle:@"Hide Desktop Icons"];
    } else {
        [toggleDesktopItem setTitle:@"Show Desktop Icons"];
    }
    [reFinderSubMenu addItem:toggleDesktopItem];
    [reFinderSubMenu addItem:[NSMenuItem separatorItem]];
    
    
    [[reFinderSubMenu addItemWithTitle:@"Settings" action:@selector(showPreferences) keyEquivalent:@""] setTarget:self];
    
    return reFinderSubMenu;
}
- (void)showPreferences {
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSURL *settingsAppPath = [workspace URLForApplicationWithBundleIdentifier:@"com.mtac.refinder"];
    [workspace openApplicationAtURL:settingsAppPath configuration:[NSWorkspaceOpenConfiguration configuration] completionHandler:nil];
}
- (void)restartFinder {
    NSLog(@"[REFINDER] : Relaunching Finder");
    float seconds = 1.0;
    NSTask *task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-c"];
    [args addObject:[NSString stringWithFormat:@"sleep %f; open \"%@\"", seconds, [[NSBundle mainBundle] bundlePath]]];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
    [NSApp terminate:nil];
}
- (void)restartDock {
    NSLog(@"[REFINDER] : Relaunching Dock");
    NSTask *task = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"-c", @"killall Dock", nil];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
}
- (BOOL)hiddenFilesAreShown {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    return [[finderDictionary objectForKey:@"AppleShowAllFiles"] boolValue];
}
- (BOOL)desktopIconsAreShown {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    return [[finderDictionary objectForKey:@"CreateDesktop"] boolValue];
}
- (void)toggleHidden:(NSMenuItem *)sender {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    if ([self hiddenFilesAreShown]) {
        [finderDictionary setValue:[NSNumber numberWithBool:0] forKey:@"AppleShowAllFiles"];
        [sender setTitle:@"0"];
    } else {
        [finderDictionary setValue:[NSNumber numberWithBool:1] forKey:@"AppleShowAllFiles"];
        [sender setTitle:@"1"];
    }
    [defaults setPersistentDomain:finderDictionary forName:@"com.apple.finder"];
    [self restartFinder];
}
- (void)toggleDesktop:(id)sender {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];

    if ([self desktopIconsAreShown]) {
        [finderDictionary setValue:[NSNumber numberWithBool:0] forKey:@"CreateDesktop"];
        [sender setTitle:@"0"];
    } else {
        [finderDictionary setValue:[NSNumber numberWithBool:1] forKey:@"CreateDesktop"];
        [sender setTitle:@"1"];
    }
    [defaults setPersistentDomain:finderDictionary forName:@"com.apple.finder"];
    [self restartFinder];
}
@end

ZKSwizzleInterface(rf_TIconOrGalleryCollectionView, TIconOrGalleryCollectionView, NSCollectionView)
@implementation rf_TIconOrGalleryCollectionView
- (void)_updateBackgroundView {
    
}
@end

ZKSwizzleInterface(rf_TBrowserWindow, TBrowserWindow, NSWindow)
@implementation rf_TBrowserWindow
- (void)setToolbar:(NSToolbar *)arg0 {
    NSToolbar *toolbar = arg0;
    [toolbar setShowsBaselineSeparator:NO];
    ZKOrig(void, toolbar);
}
- (NSToolbar *)toolbar {
    NSToolbar *toolbar = ZKOrig(NSToolbar *);
    [toolbar setShowsBaselineSeparator:NO];
    return toolbar;
}
- (void)makeKeyWindow {
    ZKOrig(void);
    removeBackground(self);
}
@end

ZKSwizzleInterface(rf__NSSplitViewItemViewWrapper, _NSSplitViewItemViewWrapper, NSView)
@implementation rf__NSSplitViewItemViewWrapper
- (id)init {
    self = ZKOrig(id);
    if (self) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBlurStyle) name:@"RFUpdateBlurStyle" object:nil];
    }
    return self;
}
- (void)layout {
    ZKOrig(void);
    [self updateBlurStyle];
}
- (void)updateBlurStyle {
    if ([defaults boolForKey:@"useTranslucency"]) {
        NSSplitViewItem *item = ((_NSSplitViewItemViewWrapper *)self).splitViewItem;
        if ([item.viewController isKindOfClass:NSClassFromString(@"TSidebarViewController")]) {
            NSVisualEffectView *effectView = ZKHookIvar(self, NSVisualEffectView *, "_effectView");
            [effectView setMaterial:selectedBlurMaterial()];
        }
    }
}
@end

ZKSwizzleInterface(rf__NSScrollViewContentBackgroundView, _NSScrollViewContentBackgroundView, NSView)
@implementation rf__NSScrollViewContentBackgroundView
- (void)updateLayer {
    if (![defaults boolForKey:@"useTranslucency"]) {
        ZKOrig(void);
    }
}
@end

ZKSwizzleInterface(rf_NSTitlebarView, NSTitlebarView, NSView);
@implementation rf_NSTitlebarView
- (id)init {
    self = ZKOrig(id);
    if (self) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBlurStyle) name:@"RFUpdateBlurStyle" object:nil];
    }
    return self;
}
- (void)layout {
    ZKOrig(void);
    RFVisualEffectView *effectView = [self viewWithTag:1000];
    if (!effectView) effectView = [[RFVisualEffectView alloc] initWithFrame:self.subviews.firstObject.frame];
    [effectView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [effectView setState:NSVisualEffectStateActive];
    [effectView setMaterial:selectedBlurMaterial()];
    if (![self.subviews containsObject:effectView]) {
        [self addSubview:effectView positioned:NSWindowBelow relativeTo:nil];
    }
    [self updateBlurStyle];
}
- (void)setMaterial:(NSVisualEffectMaterial)material {
    ZKOrig(void, selectedBlurMaterial());
}
- (void)updateBlurStyle {
    if ([self.subviews.firstObject isKindOfClass:NSClassFromString(@"NSVisualEffectView")]) {
        [(NSVisualEffectView *)self.subviews.firstObject setMaterial:selectedBlurMaterial()];
    }
    
    RFVisualEffectView *effectView = [self viewWithTag:1000];
    [effectView setMaterial:selectedBlurMaterial()];
    effectView.hidden = ![defaults boolForKey:@"useTranslucency"];
}
@end

ZKSwizzleInterface(rf_TSidebarScrollView, TSidebarScrollView, NSScrollView)
@implementation rf_TSidebarScrollView
- (_Bool)hasVerticalScroller {
    return ![[defaults objectForKey:@"hideSidebarScroller"] boolValue];
}
@end

ZKSwizzleInterface(rf_TSidebarPrefsBG, TSidebarPrefsBG, NSView)
@implementation rf_TSidebarPrefsBG
- (void)setBackgroundColor:(id)arg1 {
    ZKOrig(void, [NSColor clearColor]);
}
@end

ZKSwizzleInterface(rf_TPreferencesWindow, TPreferencesWindow, NSWindow)
@implementation rf_TPreferencesWindow
- (void)makeKeyAndOrderFront:(id)sender {
    ZKOrig(void, sender);
    removeBackground(self);
}
@end

ZKSwizzleInterface(rf_TScrollView, TScrollView, NSScrollView)
@implementation rf_TScrollView
- (NSColor *)backgroundColor {
    return [defaults boolForKey:@"useTranslucency"] ? [NSColor clearColor] : ZKOrig(NSColor *);
}
- (BOOL)drawsBackground {
    return ![defaults boolForKey:@"useTranslucency"];
}
- (_Bool)hasVerticalScroller {
    return ![defaults boolForKey:@"hideFolderScroller"];
}
@end

ZKSwizzleInterface(rf_NSSplitDividerView, NSSplitDividerView, NSView)
@implementation rf_NSSplitDividerView
- (NSColor *)backgroundColor {
    return [defaults boolForKey:@"useVibrantDivider"] ? [NSColor separatorColor] : ZKOrig(NSColor *);
}
- (double)effectiveThickness {
    return [defaults boolForKey:@"useVibrantDivider"] ? 0.5 : ZKOrig(double);
}
@end

ZKSwizzleInterface(rf_NSVibrantSplitDividerView, NSVibrantSplitDividerView, NSView)
@implementation rf_NSVibrantSplitDividerView
- (void)setBackgroundColor:(id)color {
    ZKOrig(void, ([defaults boolForKey:@"useVibrantDivider"] ? [NSColor clearColor] : color));
}
- (NSAppearance *)_preferredAppearance {
    return [defaults boolForKey:@"useVibrantDivider"] ? [NSAppearance _vibrantLightAppearance] : ZKOrig(NSAppearance *);
}
- (void)setThickness:(id)thickness {
    ZKOrig(void, ([defaults boolForKey:@"useVibrantDivider"] ? [NSNumber numberWithDouble:0.0] : thickness));
}
@end

ZKSwizzleInterface(rf_NSTitlebarContainerView, NSTitlebarContainerView, NSView)
@implementation rf_NSTitlebarContainerView
- (BOOL)drawsBottomSeparator {
    return ![defaults boolForKey:@"useTranslucency"];
}
- (void)setDrawsBottomSeparator:(BOOL)arg0 {
    ZKOrig(void, ![defaults boolForKey:@"useTranslucency"]);
}
@end

ZKSwizzleInterface(rf__NSTitlebarDecorationView, _NSTitlebarDecorationView, NSView)
@implementation rf__NSTitlebarDecorationView
- (BOOL)drawsBottomSeparator {
    return ![defaults boolForKey:@"useTranslucency"];
}
- (void)setDrawsBottomSeparator:(BOOL)arg0 {
    ZKOrig(void, ![defaults boolForKey:@"useTranslucency"]);
}
@end

ZKSwizzleInterface(rf_NSClipView, NSClipView, NSView)
@implementation rf_NSClipView
- (NSColor *)backgroundColor {
    NSColor *returnColor = ZKOrig(NSColor *);
    if ([defaults boolForKey:@"useTranslucency"]) {
        if ([((NSClipView *)self).subviews.firstObject isKindOfClass:object_getClass(@"TListView")]) {
            returnColor = [NSColor clearColor];
        }
    }
    return returnColor;
}
@end

ZKSwizzleInterface(rf_TListView, TListView, NSOutlineView)
@implementation rf_TListView
- (NSColor *)backgroundColor {
    return [defaults boolForKey:@"useTranslucency"] ? [NSColor clearColor] : ZKOrig(NSColor *);
}
- (_Bool)usesAlternatingRowBackgroundColors {
    return ![defaults boolForKey:@"useTranslucency"];
}
@end

ZKSwizzleInterface(rf_TListHeaderRowView, TListHeaderRowView, NSView)
@implementation rf_TListHeaderRowView
- (_Bool)_drawsGroupRowBackground {
    return ![defaults boolForKey:@"useTranslucency"];
}
@end

ZKSwizzleInterface(rf_TListRowView, TListRowView, NSTableRowView)
@implementation rf_TListRowView
- (void)_setupBackgroundLayer:(id)layer {
    
}
- (_Bool)_drawsGroupRowBackground {
    return YES;
}
- (void)_drawSourceListBackgroundInnerEdgeInRect:(CGRect)rect {
    
}
- (void)setSelectionBlendingMode:(long long)mode {
    ZKOrig(void, 0);
}
- (_Bool)_shouldUseBackgroundColor {
    return NO;
}
- (_Bool)_hasSourceListBackground {
    return NO;
}
@end

ZKSwizzleInterface(rf_TColumnView, TColumnView, NSBrowser)
@implementation rf_TColumnView
- (NSColor *)backgroundColor {
    return [defaults boolForKey:@"useTranslucency"] ? [NSColor clearColor] : ZKOrig(NSColor *);
}
@end

ZKSwizzleInterface(rf_TQuickActionsViewController, TQuickActionsViewController, NSViewController)
@implementation rf_TQuickActionsViewController
- (void)viewWillLayout {
    ZKOrig(void);
    if ([defaults boolForKey:@"useTranslucency"]) {
        NSStackView *stackView = ZKHookIvar(self, NSStackView *, "_stackView");
        stackView.layer.backgroundColor = [NSColor clearColor].CGColor;
    }
}
@end

ZKSwizzleInterface(rf_TContextMenu, TContextMenu, NSMenu)
@implementation rf_TContextMenu
+ (void)buildContextMenu:(id)menu forContext:(int)context contextMenuDelegate:(id)delegate clickedView:(NSView *)view maxItems:(unsigned long long)items addServices:(_Bool)services {
    
    if ([defaults boolForKey:@"addCopyPathItem"] || [defaults boolForKey:@"addNewFileItem"]) {
        if (browserRootPath) {
            browserRootPath = nil;
        }
        if ([[(NSView *)view window] isKindOfClass:NSClassFromString(@"TBrowserWindow")]) {
            if ([view isKindOfClass:NSClassFromString(@"TIconCollectionView")]) {
                TIconCollectionView *collectionView = (TIconCollectionView *)view;
                NSIndexPath *path = [collectionView _firstSelectionIndexPath];
                browserRootPath = path;
            }
            if ([view isKindOfClass:NSClassFromString(@"TListView")]) {
                TListView *listView = (TListView *)view;
                selectedListRow = [listView selectedRow];
            }
            if ([view isKindOfClass:NSClassFromString(@"TColumnView")]) {
                TColumnView *columnView = (TColumnView *)view;
                browserRootPath = columnView.selectionIndexPath;
                columnPath = [columnView path];
            }
        }
    }
    ZKOrig(void, menu, context, delegate, view, items, services);
}
@end

ZKSwizzleInterface(rf_TBrowserViewController, TBrowserViewController, NSViewController)
@implementation rf_TBrowserViewController
- (void)menuWillOpen:(NSMenu *)open {
    if ([[self.view window] isKindOfClass:NSClassFromString(@"TBrowserWindow")]) {
        NSMenuItem *refinderItem = [[NSMenuItem alloc] initWithTitle:@"ReFinder" action:nil keyEquivalent:@""];
        
        NSMenuItem *copyPath = [[NSMenuItem alloc] initWithTitle:@"Copy Path" action:@selector(copyPath) keyEquivalent:@""];
        [copyPath setTarget:self];
        
        NSMenuItem *newFile = [[NSMenuItem alloc] initWithTitle:@"New File" action:@selector(createNewFile) keyEquivalent:@""];
        [newFile setTarget:self];
        
        NSMenu *refinderMenu = [[NSMenu alloc] init];
        if ([defaults boolForKey:@"addCopyPathItem"]) {
            [refinderMenu addItem:copyPath];
        }
        if ([defaults boolForKey:@"addNewFileItem"]) {
            [refinderMenu addItem:newFile];
        }
        
        if (refinderMenu.itemArray.count > 0) {
            [open addItem:[NSMenuItem separatorItem]];
            [open addItem:refinderItem];
            [open setSubmenu:refinderMenu forItem:refinderItem];
        }
    }
    ZKOrig(void, open);
}
- (NSString *)browserPath {
    struct TFENode tfenode = *[(TBrowserViewController *)self browserRoot];
    FINode *node = [objc_getClass("FINode") nodeFromNodeRef:tfenode.x0];
    NSString *rep = [NSString stringWithUTF8String:[node.fileURL fileSystemRepresentation]];
    return rep;
}
- (NSString *)targetPath {
    struct TFENode tfenode = *[(TBrowserViewController *)self target];
    FINode *node = [objc_getClass("FINode") nodeFromNodeRef:tfenode.x0];
    NSString *rep = [NSString stringWithUTF8String:[node.fileURL fileSystemRepresentation]];
    return rep;
}
- (void)copyPath {
    NSString *copyString;
    if ([[(TBrowserViewController *)self browserView] isKindOfClass:NSClassFromString(@"TIconCollectionView")]) {
        TIconCollectionView *collectionView = (TIconCollectionView *)[(TBrowserViewController *)self browserView];
        NSInteger selectedIndexesCount = [collectionView.selectionIndexPaths.allObjects count];
        TIconView *iconView = [collectionView iconViewForIndexPath:browserRootPath];
        if (selectedIndexesCount == 0) {
            copyString = [self browserPath];
        } else {
            copyString = [NSString stringWithFormat:@"%@/%@", [self browserPath], iconView.titleStr];
        }
    } else if ([[(TBrowserViewController *)self browserView] isKindOfClass:NSClassFromString(@"TListView")]) {
        TListView *listView = (TListView *)[(TBrowserViewController *)self browserView];
        if (selectedListRow == -1) {
            copyString = [self browserPath];
        } else {
            FIDSNode *fileNode = (FIDSNode *)[listView itemAtRow:selectedListRow];
            NSString *rep = [NSString stringWithUTF8String:[fileNode.fileURL fileSystemRepresentation]];
            copyString = rep;
        }
    } else if ([[(TBrowserViewController *)self browserView] isKindOfClass:NSClassFromString(@"TColumnView")]) {
        
        TColumnView *columnView = (TColumnView *)[(TBrowserViewController *)self browserView];
        struct TFENode tfenode = *[(TBrowserViewController *)self browserRoot];
        FINode *node = [objc_getClass("FINode") nodeFromNodeRef:tfenode.x0];
        NSString *browserRoot = [NSString stringWithUTF8String:[[node previewItemURL] fileSystemRepresentation]];
        
        NSInteger selectedIndexesCount = [columnView.selectionIndexPaths count];
        if (selectedIndexesCount == 0) {
            copyString = browserRoot;
        } else {
            copyString = [NSString stringWithFormat:@"%@%@", browserRoot, columnPath];
        }
    }
    
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:copyString forType:NSPasteboardTypeString];
}
- (void)createNewFile {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Create New File"];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    input.bezelStyle = NSTextFieldRoundedBezel;

    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        NSString *inputTitle = input.stringValue;
        if (inputTitle != nil || ![inputTitle isEqualToString:@""]) {
            NSData *fileContents = [@"" dataUsingEncoding:NSUTF8StringEncoding];
            [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/%@", [self browserPath], input.stringValue] contents:fileContents attributes:nil];
        }
    } else if (button == NSAlertSecondButtonReturn) {
        return;
    }
}
@end

ZKSwizzleInterface(rf_FIDSNode, FIDSNode, NSObject)
@implementation rf_FIDSNode
- (NSURL *)previewItemURL {
    return ZKOrig(NSURL *);
}
- (NSString *)previewItemTitle {
    NSString *title = ZKOrig(NSString *);
    if ([defaults boolForKey:@"showFileSize"]) {
        NSString *rep = [NSString stringWithUTF8String:[[self previewItemURL] fileSystemRepresentation]];
        NSImage *fileImage = [[NSImage alloc] initWithContentsOfFile:rep];
        NSImageRep *fileRepresentation = [fileImage.representations firstObject];
        BOOL isDirectory;
        NSDictionary *attributes;
        NSString *byteString;
        if ([[NSFileManager defaultManager] fileExistsAtPath:rep isDirectory:&isDirectory]) {
            attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:rep error:nil];
            byteString = [NSByteCountFormatter stringFromByteCount:[attributes fileSize] countStyle:NSByteCountFormatterCountStyleFile];
        }
        
        if (!isDirectory) {
            NSString *fileName = ZKOrig(NSString *);
            if (fileImage != nil) {
                title = [NSString stringWithFormat:@"%@ • %@ • %ld⨉%ld", fileName, byteString, fileRepresentation.pixelsWide, fileRepresentation.pixelsHigh];
            } else {
                title = [NSString stringWithFormat:@"%@ • %@", fileName, byteString];
            }
        }
    }
    return title;
}
@end

__attribute__((constructor)) static void init(void) {
    @autoreleasepool {
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.mtac.refinder"];
    }
}
