define :php_version, :version => 5 do
  system "php -v | grep -qs 'PHP #{params[:version]}'"
end