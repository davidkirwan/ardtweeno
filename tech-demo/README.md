## tech-demo Sinatra Web App
This tech-demo is a sample web application using the Ardtweeno API. This does need a lot of work so
don't expect too much! I've rushed to get as far as I have with it, you currently need to manually
update the 14 or so API calls to match the IP of the Ardtweeno gateway. Find and replace all instances
of 'localhost' with what ever the IP of the gateway is. I'll get around to fixing this asap. After I've
had a holiday tbh. ha!

### Operation
To first download the dependencies run the following:

    bundle install

Edit the YAML file _config.yaml_ to match the correct network settings for the Ardtweeno Gateway then to
launch on port 5000 simply run:

    foreman start -p 5000


