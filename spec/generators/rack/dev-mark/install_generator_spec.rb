require 'spec_helper'

if defined?(::Rails)
require 'tempfile'
require 'generators/rack/dev-mark/install_generator'
describe Rack::DevMark::InstallGenerator do
  include_context 'forked spec'

  context "config/application.rb" do
    let(:application_rb) { Tempfile.new('config_application.rb') }
    before do
      application_rb.write <<-EOS
module MyApp
  class Application < Rails::Application
    # ...
  end
end
      EOS
      application_rb.rewind
      allow_any_instance_of(Rack::DevMark::InstallGenerator).to receive(:target_path).and_return(application_rb.path)
    end
    after do
      application_rb.close
      application_rb.unlink
    end

    it 'inserts rack-dev-mark settings' do
      Rails::Generators.invoke("rack:dev-mark:install")
      application_rb.rewind
      expect(application_rb.read).to eq <<-EOS
module MyApp
  class Application < Rails::Application
    # Enable rack-dev-mark
    config.rack_dev_mark.enable = !Rails.env.production?
    # Customize themes if you want to do so
    # config.rack_dev_mark.theme = [:title, :github_fork_ribbon]

    # ...
  end
end
      EOS
    end
  end
end
end
