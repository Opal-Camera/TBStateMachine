Pod::Spec.new do |s|
  s.name             = "TBStateMachine"
  s.version          = "6.10.0"
  s.summary          = "A lightweight hierarchical state machine framework in Objective-C."
  s.description      = <<-DESC
                       Supports all common features of a UML state machine like:

                       - nested states
                       - orthogonal regions
                       - pseudo states
                       - transitions with guards and actions
                       - state switching using least common ancestor algorithm and run-to-completion model
                       DESC
  s.homepage         = "https://github.com/jkrumow/TBStateMachine"
  s.license          = 'MIT'
  s.author           = { "Julian Krumow" => "julian.krumow@bogusmachine.com" }

  s.ios.deployment_target = '6.0'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.8'

  s.requires_arc = true
  s.source = { :git => "https://github.com/jkrumow/TBStateMachine.git", :tag => s.version.to_s }

  s.default_subspec = 'Core'
  s.subspec 'Core' do |core|
    core.source_files = 'Sources/TBStateMachine/Core/*.{h,m}'
  end

  s.subspec 'Builder' do |builder|
    builder.source_files = 'Sources/TBStateMachine/Builder/*.{h,m}'
    builder.resource_bundle = { 'TBStateMachineBuilder' => 'Sources/TBStateMachine/Builder/Schema/*.json' }
    builder.dependency 'TBStateMachine/Core'
  end
  
  s.subspec 'DebugSupport' do |debug|
    debug.source_files = 'Sources/TBStateMachine/DebugSupport/*.{h,m}'
    debug.dependency 'TBStateMachine/Core'
  end
end
