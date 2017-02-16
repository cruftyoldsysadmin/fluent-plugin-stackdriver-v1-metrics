# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-stackdriver-metrics"
  gem.version       = "0.1.0"
  gem.authors       = ["Alex Yamauchi"]
  gem.email         = ["alex.yamauchi@hotschedules.com"]
  gem.summary       = %q{A Fluent buffered output plugin to send metrics to StackDriver using the V1 (pre-Google) API}
  gem.description   = gem.summary
  gem.files         = `git ls-files`.split($\)
  gem.require_paths = ["lib"]
  gem.license       = "Apache-2.0"
  gem.add_runtime_dependency "fluentd", ">= 0.10.0"
  gem.add_runtime_dependency "stackdriver", ">= 0.4.0"
end
