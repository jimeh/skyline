# Skyline

Skyline allows you to send shell commands to all machines in any one, or all AutoScaling groups in your Amazon EC2 account.


## Requirements

* Ruby
* [Amazon EC2 account][ec2]
* [Amazon EC2 API tools][ec2tools]
* [Amazon AutoScaling tools][astools]
* At least one AutoScaling group with instances


## Usage

Get Skyline:

    git clone git://github.com/jimeh/skyline.git

If you're using a custom SSH key, define it in `skyline_config.yml`:

    ssh_key: ~/.ec2/kp_jimeh_default

Run Skyline and it's help command:

    ./skyline
    help_me

The pure basics are:
* Select an AutoScaling group with the `use` command
* Use the `icmd` command to enter an interactive shell where everything you enter runs in parallel on all machines within selected AutoScaling group.


## Notes / Warnings

* I created this tool in a hurry back in September to auto-scale a then fast growing Facebook application, and I haven't really touched it since. As such, it's not perfect, definitely has some bad code, and generally is far from perfect. That said, it does work, and works very well. If there's something that can be done better, don't hesitate to fork and send me a pull request :)

* This tool was originally mean to be used together with [Skyhook][skyhook]. But it's perfectly useful as a standalone tool.


## License

(The MIT License)

Copyright (c) 2009 Jim Myhrberg

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.




[ec2]: http://aws.amazon.com/ec2/
[ec2tools]: http://developer.amazonwebservices.com/connect/entry.jspa?externalID=351&categoryID=88
[astools]: http://developer.amazonwebservices.com/connect/entry.jspa?externalID=2535&categoryID=88
[skyhook]: git://github.com/jimeh/skyhook.git