#!/bin/bash

echo "🔧 Creating Xcode project for Stripe to QuickBooks Converter..."

# Create the project directory structure
mkdir -p "StripeConverter.xcodeproj/project.xcworkspace/xcshareddata"
mkdir -p "StripeConverter/Supporting Files"
mkdir -p "StripeConverter/Preview Content"

# Create the proper project.pbxproj file
cat > "StripeConverter.xcodeproj/project.pbxproj" << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		A1B2C3D4E5F60001 /* StripeConverterApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F60002 /* StripeConverterApp.swift */; };
		A1B2C3D4E5F60003 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F60004 /* ContentView.swift */; };
		A1B2C3D4E5F60005 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F60006 /* Assets.xcassets */; };
		A1B2C3D4E5F60007 /* Preview Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F60008 /* Preview Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		A1B2C3D4E5F60000 /* StripeConverter.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = StripeConverter.app; sourceTree = BUILT_PRODUCTS_DIR; };
		A1B2C3D4E5F60002 /* StripeConverterApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StripeConverterApp.swift; sourceTree = "<group>"; };
		A1B2C3D4E5F60004 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		A1B2C3D4E5F60006 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		A1B2C3D4E5F60008 /* Preview Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Preview Assets.xcassets"; sourceTree = "<group>"; };
		A1B2C3D4E5F60009 /* StripeConverter.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = StripeConverter.entitlements; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		A1B2C3D4E5F5FFFD /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		A1B2C3D4E5F5FFF7 = {
			isa = PBXGroup;
			children = (
				A1B2C3D4E5F60001 /* StripeConverter */,
				A1B2C3D4E5F5FFF8 /* Products */,
			);
			sourceTree = "<group>";
		};
		A1B2C3D4E5F5FFF8 /* Products */ = {
			isa = PBXGroup;
			children = (
				A1B2C3D4E5F60000 /* StripeConverter.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		A1B2C3D4E5F60001 /* StripeConverter */ = {
			isa = PBXGroup;
			children = (
				A1B2C3D4E5F60002 /* StripeConverterApp.swift */,
				A1B2C3D4E5F60004 /* ContentView.swift */,
				A1B2C3D4E5F60006 /* Assets.xcassets */,
				A1B2C3D4E5F60009 /* StripeConverter.entitlements */,
				A1B2C3D4E5F60007 /* Preview Content */,
			);
			path = StripeConverter;
			sourceTree = "<group>";
		};
		A1B2C3D4E5F60007 /* Preview Content */ = {
			isa = PBXGroup;
			children = (
				A1B2C3D4E5F60008 /* Preview Assets.xcassets */,
			);
			path = "Preview Content";
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		A1B2C3D4E5F5FFFF /* StripeConverter */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A1B2C3D4E5F6000A /* Build configuration list for PBXNativeTarget "StripeConverter" */;
			buildPhases = (
				A1B2C3D4E5F5FFFC /* Sources */,
				A1B2C3D4E5F5FFFD /* Frameworks */,
				A1B2C3D4E5F5FFFE /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = StripeConverter;
			productName = StripeConverter;
			productReference = A1B2C3D4E5F60000 /* StripeConverter.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		A1B2C3D4E5F5FFF8 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					A1B2C3D4E5F5FFFF = {
						CreatedOnToolsVersion = 15.0;
						LastSwiftMigration = 1500;
					};
				};
			};
			buildConfigurationList = A1B2C3D4E5F5FFFB /* Build configuration list for PBXProject "StripeConverter" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = A1B2C3D4E5F5FFF7;
			productRefGroup = A1B2C3D4E5F5FFF8 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				A1B2C3D4E5F5FFFF /* StripeConverter */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		A1B2C3D4E5F5FFFE /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1B2C3D4E5F60007 /* Preview Assets.xcassets in Resources */,
				A1B2C3D4E5F60005 /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		A1B2C3D4E5F5FFFC /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1B2C3D4E5F60003 /* ContentView.swift in Sources */,
				A1B2C3D4E5F60001 /* StripeConverterApp.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		A1B2C3D4E5F6000B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		A1B2C3D4E5F6000C /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		A1B2C3D4E5F6000D /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = StripeConverter/StripeConverter.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"StripeConverter/Preview Content\"";
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "Stripe to QuickBooks Converter";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.finance";
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stripe.quickbooks.converter;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		A1B2C3D4E5F6000E /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = StripeConverter/StripeConverter.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"StripeConverter/Preview Content\"";
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "Stripe to QuickBooks Converter";
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.finance";
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stripe.quickbooks.converter;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A1B2C3D4E5F5FFFB /* Build configuration list for PBXProject "StripeConverter" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1B2C3D4E5F6000B /* Debug */,
				A1B2C3D4E5F6000C /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		A1B2C3D4E5F6000A /* Build configuration list for PBXNativeTarget "StripeConverter" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1B2C3D4E5F6000D /* Debug */,
				A1B2C3D4E5F6000E /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = A1B2C3D4E5F5FFF8 /* Project object */;
}
EOF

echo "✅ Xcode project structure created!"
echo "📁 Project: StripeConverter.xcodeproj"