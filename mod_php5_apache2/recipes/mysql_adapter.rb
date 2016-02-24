package 'php-mysql' do
  options '--force-yes'
  package_name value_for_platform_family(
    'rhel'   => 'php-mysql',
    'debian' => 'php7.0-mysql'
  )
end
