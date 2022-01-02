{ config, lib, pkgs, ... }:

{
  services = {
    selfoss = {
      enable = true;
      database = {
        type = "pgsql";
        password = "notsosecret";
      };
    };
    nginx = {
      enable = true;
      virtualHosts."nanashi0x74.dev".locations."/feedreader" = {
        root = "/var/lib/selfoss";
        index = "index.php";
        extraConfig = let fpm = config.services.phpfpm.pools.${config.services.selfoss.pool}; in ''
	  location ~ ^/feedreader/php/(.*)$ {
	    alias /var/lib/selfoss/index.php?$1;
            fastcgi_pass unix:${fpm.socket};
	    fastcgi_param  SCRIPT_FILENAME /var/lib/selfoss/index.php;                                                                                     
	    fastcgi_param  SCRIPT_NAME /selfoss/index.php;
	    fastcgi_param  REQUEST_URI        /selfoss/$1;
	    fastcgi_param  QUERY_STRING       $query_string;
	    fastcgi_param  REQUEST_METHOD     $request_method;
	    fastcgi_param  CONTENT_TYPE       $content_type;
	    fastcgi_param  CONTENT_LENGTH     $content_length;
	    #fastcgi_param  REQUEST_URI        $request_uri;
	    fastcgi_param  DOCUMENT_URI       $document_uri;
	    fastcgi_param  DOCUMENT_ROOT      $document_root;
	    fastcgi_param  SERVER_PROTOCOL    $server_protocol;
	    fastcgi_param  REQUEST_SCHEME     $scheme;
	    fastcgi_param  HTTPS              $https if_not_empty;
	    fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
	    fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;                                                                                       
	    fastcgi_param  REMOTE_ADDR        $remote_addr;
	    fastcgi_param  REMOTE_PORT        $remote_port;
	    fastcgi_param  SERVER_ADDR        $server_addr;
	    fastcgi_param  SERVER_PORT        $server_port;
	    fastcgi_param  SERVER_NAME        $server_name;
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
	  }
	  location ~ ^/feedreader/(.*)$ {
            try_files /public/$1 /selfoss/php/$1$is_args$args;
          }
        '';
      };
    };
  };


}
