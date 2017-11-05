
#@load base/protocols/http;
module HTTP;

export {
	const sensitive_URIs =
		  /etc\/(passwd|shadow|netconfig)/
		| /IFS[ \t]*=/
		| /nph-test-cgi\?/
		| /(%0a|\.\.)\/(bin|etc|usr|tmp)/
		| /\/Admin_files\/order\.log/
		| /\/carbo\.dll/
		| /\/cgi-bin\/(phf|php\.cgi|test-cgi)/
		| /\/cgi-dos\/args\.bat/
		| /\/cgi-win\/uploader\.exe/
		| /\/search97\.vts/
		| /tk\.tgz/
		| /ownz/	# somewhat prone to false positives
		| /viewtopic\.php.*%.*\(.*\(/	# PHP attack, 26Nov04
		# a bunch of possible rootkits
		| /sshd\.(tar|tgz).*/
		| /[aA][dD][oO][rR][eE][bB][sS][dD].*/
		# | /[tT][aA][gG][gG][eE][dD].*/	# prone to FPs
		| /shv4\.(tar|tgz).*/
		| /lrk\.(tar|tgz).*/
		| /lyceum\.(tar|tgz).*/
		| /maxty\.(tar|tgz).*/
		| /rootII\.(tar|tgz).*/
		| /invader\.(tar|tgz).*/
	&redef;

	# Used to look for attempted password file fetches.
	const passwd_URI = /passwd/ &redef;

	# URIs that match sensitive_URIs but can be generated by worms,
	# and hence should not be flagged (because they're so common).
	const worm_URIs =
		  /.*\/c\+dir/
		| /.*cool.dll.*/
		| /.*Admin.dll.*Admin.dll.*/
	&redef;

	# URIs that should not be considered sensitive if accessed by
	# a local client.
	const skip_remote_sensitive_URIs =
		/\/cgi-bin\/(phf|php\.cgi|test-cgi)/
	&redef;
	

	const sensitive_post_URIs = /wwwroot|WWWROOT/ 
	&redef;
	
	const sql_injection_uri = 
		  /[\?&][^[:blank:]\x00-\x37\|]+?=[\-[:alnum:]%]+([[:blank:]\x00-\x37]|\/\*.*?\*\/)*['"]?([[:blank:]\x00-\x37]|\/\*.*?\*\/|\)?;)+.*?([hH][aA][vV][iI][nN][gG]|[uU][nN][iI][oO][nN]|[eE][xX][eE][cC]|[sS][eE][lL][eE][cC][tT]|[dD][eE][lL][eE][tT][eE]|[dD][rR][oO][pP]|[dD][eE][cC][lL][aA][rR][eE]|[cC][rR][eE][aA][tT][eE]|[iI][nN][sS][eE][rR][tT])([[:blank:]\x00-\x37]|\/\*.*?\*\/)+/
		| /[\?&][^[:blank:]\x00-\x37\|]+?=[\-0-9%]+([[:blank:]\x00-\x37]|\/\*.*?\*\/)*['"]?([[:blank:]\x00-\x37]|\/\*.*?\*\/|\)?;)+([xX]?[oO][rR]|[nN]?[aA][nN][dD])([[:blank:]\x00-\x37]|\/\*.*?\*\/)+['"]?(([^a-zA-Z&]+)?=|[eE][xX][iI][sS][tT][sS])/
		| /[\?&][^[:blank:]\x00-\x37]+?=[\-0-9%]*([[:blank:]\x00-\x37]|\/\*.*?\*\/)*['"]([[:blank:]\x00-\x37]|\/\*.*?\*\/)*(-|=|\+|\|\|)([[:blank:]\x00-\x37]|\/\*.*?\*\/)*([0-9]|\(?[cC][oO][nN][vV][eE][rR][tT]|[cC][aA][sS][tT])/
		| /[\?&][^[:blank:]\x00-\x37\|]+?=([[:blank:]\x00-\x37]|\/\*.*?\*\/)*['"]([[:blank:]\x00-\x37]|\/\*.*?\*\/|;)*([xX]?[oO][rR]|[nN]?[aA][nN][dD]|[hH][aA][vV][iI][nN][gG]|[uU][nN][iI][oO][nN]|[eE][xX][eE][cC]|[sS][eE][lL][eE][cC][tT]|[dD][eE][lL][eE][tT][eE]|[dD][rR][oO][pP]|[dD][eE][cC][lL][aA][rR][eE]|[cC][rR][eE][aA][tT][eE]|[rR][eE][gG][eE][xX][pP]|[iI][nN][sS][eE][rR][tT])([[:blank:]\x00-\x37]|\/\*.*?\*\/|[\[(])+[a-zA-Z&]{2,}/
		| /[\?&][^[:blank:]\x00-\x37]+?=[^\.]*?([cC][hH][aA][rR]|[aA][sS][cC][iI][iI]|[sS][uU][bB][sS][tT][rR][iI][nN][gG]|[tT][rR][uU][nN][cC][aA][tT][eE]|[vV][eE][rR][sS][iI][oO][nN]|[lL][eE][nN][gG][tT][hH])\(/
		| /\/\*![[:digit:]]{5}.*?\*\// 
	&redef;
}


event http_request(c:connection,method: string, original_URI: string, unescaped_URI: string, version: string) {
    print fmt("HTTP REQUEST");
    #local URI1 = unescaped_URI;
    local URI2 = original_URI;

    if (sql_injection_uri in URI2 ){
		print fmt("ID: %s SQL INJECTION DETECTED in %s from IP: %s | String: %s ", c$uid, method, c$id$orig_h, unescaped_URI);
		#print fmt("ORIG %s", original_URI);
    }

}
