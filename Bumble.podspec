Pod::Spec.new do |s|
    s.name         = 'Bumble'

    s.version      = '1.0.7'

    s.summary      = 'Now add Agent in app for quick support.'
    s.homepage     = 'https://github.com/Jungle-Works/bumble-ios'
    s.documentation_url = 'https://github.com/Jungle-Works/bumble-ios'
    
    s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }
    
    s.author             = { 'utkarsh' => 'utkarsh.shukla@jungleworks.com' }
    
    s.source       = { :git => 'https://github.com/Jungle-Works/bumble-ios.git', :tag => s.version }
    s.ios.deployment_target = '10.0'
    s.source_files = 'Hippo/**/*.{swift,h,m}'
    s.exclude_files = 'Classes/Exclude'
    s.static_framework = false
    
    s.swift_version = '4.2'
    
    s.resource_bundles = {
        'Hippo' => ['Hippo/*.{lproj,storyboard,xcassets,gif}','Hippo/Assets/**/*.imageset','Hippo/UIView/TableViewCell/**/*.xib','Hippo/UIView/CollectionViewCells/**/*.xib','Hippo/UIView/CustomViews/**/*.xib','Hippo/InternalClasses/Views/**/*.xib','Hippo/InternalClasses/Module/**/*.xib', 'Hippo/**/*.gif','Hippo/Language/**/*.strings', 'README.md']
    }
    s.resources = ['Hippo/*.xcassets']
    s.preserve_paths = ['README.md']   
    
end
