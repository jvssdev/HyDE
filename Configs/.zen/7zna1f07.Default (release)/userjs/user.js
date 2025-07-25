/****************************************************************************************
 * Smoothfox                                                                            *
 * "Faber est suae quisque fortunae"                                                    *
 * priority: better scrolling                                                           *
 * version: 126.1                                                                       *
 * url: https://github.com/yokoffing/Betterfox                                          *
 ***************************************************************************************/

// Use only one option at a time!
// Reset prefs if you decide to use different option.

/****************************************************************************************
 * OPTION: SHARPEN SCROLLING                                                           *
 ****************************************************************************************/
// credit: https://github.com/black7375/Firefox-UI-Fix
// only sharpen scrolling
// user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
// user_pref("general.smoothScroll", true); // DEFAULT
// user_pref("mousewheel.min_line_scroll_amount", 10); // 10-40; adjust this number to your liking; default=5
// user_pref("general.smoothScroll.mouseWheel.durationMinMS", 80); // default=50
// user_pref("general.smoothScroll.currentVelocityWeighting", "0.15"); // default=.25
// user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6"); // default=.4
// Firefox Nightly only:
// [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1846935
// user_pref("general.smoothScroll.msdPhysics.enabled", false); // [FF122+ Nightly]

/****************************************************************************************
 * OPTION: INSTANT SCROLLING (SIMPLE ADJUSTMENT)                                       *
 ****************************************************************************************/
// recommended for 60hz+ displays
// user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
// user_pref("general.smoothScroll", true); // DEFAULT
// user_pref("mousewheel.default.delta_multiplier_y", 275); // 250-400; adjust this number to your liking
// // Firefox Nightly only:
// // [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1846935
// user_pref("general.smoothScroll.msdPhysics.enabled", false); // [FF122+ Nightly]

/****************************************************************************************
 * OPTION: SMOOTH SCROLLING                                                            *
 ****************************************************************************************/
// recommended for 90hz+ displays
user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("general.smoothScroll", true); // DEFAULT
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("mousewheel.default.delta_multiplier_y", 250); // 250-400; adjust this number to your liking

/****************************************************************************************
 * OPTION: NATURAL SMOOTH SCROLLING V3 [MODIFIED]                                      *
 ****************************************************************************************/
// credit: https://github.com/AveYo/fox/blob/cf56d1194f4e5958169f9cf335cd175daa48d349/Natural%20Smooth%20Scrolling%20for%20user.js
// recommended for 120hz+ displays
// largely matches Chrome flags: Windows Scrolling Personality and Smooth Scrolling
// user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
// user_pref("general.smoothScroll", true); // DEFAULT
// user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
// user_pref("general.smoothScroll.msdPhysics.enabled", true);
// user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
// user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
// user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
// user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "2");
// user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
// user_pref("general.smoothScroll.currentVelocityWeighting", "1");
// user_pref("general.smoothScroll.stopDecelerationWeighting", "1");
// user_pref("mousewheel.default.delta_multiplier_y", 300); // 250-400; adjust this number to your liking

// Custom Options
user_pref("ui.key.menuAccessKey", 0);
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("zen.urlbar.replace-newtab", false);
user_pref("zen.workspaces.open-new-tab-if-last-unpinned-tab-is-closed", false);
user_pref("browser.tabs.groups.enabled", false);
user_pref("browser.urlbar.trimURLs", true);
user_pref("zen.theme.gradient", true);
user_pref("zen.view.experimental-rounded-view", true);
user_pref("toolkit.tabbox.switchByScrolling", false);
user_pref("zen.widget.linux.transparency", true);
user_pref("zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url", true);
user_pref("zen.splitView.change-on-hover", true);
user_pref("zen.tabs.show-newtab-under", false);
user_pref("zen.tabs.show-newtab-button-top", false);
user_pref("zen.tabs.show-newtab-vertical", false);
user_pref("zen.urlbar.behavior", "float");
user_pref("zen.view.compact.hide-toolbar", true);
user_pref("zen.workspaces.force-container-workspace", true);
user_pref("zen.glance.open-essential-external-links", false);
user_pref("browser.tabs.allow_transparent_browser", false);
user_pref("browser.engagement.ctrlTab.has-used", true);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);
user_pref("browser.translations.automaticallyPopup", false);
