module Utils
  module Helper

    include Chef::Mixin::ShellOut

    def missing_php?
      version = 7
      !shell_out!("php -v | grep -qs 'PHP #{version}'")
    end
  end
end
