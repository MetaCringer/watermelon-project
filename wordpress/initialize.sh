#!/bin/bash
wp post create \
  --post_type=post \
  --post_title='Реєстрація' \
  --post_content=" 
<!-- wp:buttons -->
<div class=\"wp-block-buttons\"><!-- wp:button -->
<div class=\"wp-block-button\"><a class=\"wp-block-button__link\" href=\"http://${WP_URL}/wp-login.php/\">Реєстрація</a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons -->" \
  --post_status='publish'
( echo "cat <<EOF" ; cat /app/wp-telegram-config.json.template ) | sh > /app/wp-telegram-config.json
wp option add wptelegram_login --format=json --autoload=yes < /app/wp-telegram-config.json
wp db query < /app/launcher-patch.sql