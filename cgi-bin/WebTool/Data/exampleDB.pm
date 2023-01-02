package Data::exampleDB;

$everything = {
	"content_string" => "<h1>Welcome to Web Tool!</h1>\r\n      <p>Let us know if you have any problems or questions: email support\@chicodigital.com<br>\r\n      ",
	"links1" => {
          "yet another page" => {
                                  "content_string" => "",
                                  "link_order1" => [
                                                     "test 1"
                                                   ],
                                  "links1" => {
                                                "test 1" => {
                                                              "content_string" => "Hello\r\n\r\nmy name is Joe.\r\n",
                                                              "links1" => {},
                                                              "link_order1" => [],
                                                              "template_file" => "default.html"
                                                            }
                                              },
                                  "template_file" => "default.html"
                                },
          "test page 1" => {
                             "content_string" => "this is another test\r\n\r\nthis is another test\r\n\r\n<h1> hello </h1>\r\n",
                             "links1" => {
                                           "hello" => {
                                                        "content_string" => "",
                                                        "links1" => {},
                                                        "link_order1" => [],
                                                        "template_file" => "default.html"
                                                      }
                                         },
                             "link_order1" => [
                                                "hello"
                                              ],
                             "template_file" => "default.html"
                           },
          "another page" => {
                              "content_string" => "",
                              "links1" => {},
                              "link_order1" => [],
                              "template_file" => "default.html"
                            }
        },
	"link_order1" => [
          "test page 1",
          "another page",
          "yet another page"
        ],
	"template_file" => "default2.html"

};

1;


