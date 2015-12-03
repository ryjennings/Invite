Parse.Cloud.define("email_template", function(request, response) {
    var Mandrill = require("cloud/mandrill.js");
    Mandrill.initialize("Siq4OT7iNAYop8Fr8HbdAQ");
    Mandrill.sendTemplate({

        template_name: request.params.template,
        template_content: [{
            name: "example name",
            content: "example content" // Required, but not used
        }],
        message: {
            to: request.params.to,
            auto_text: true,
            inline_css: true,
            merge: true,
            merge_language: "handlebars",
            global_merge_vars: request.params.global_merge_vars,
            subject: request.params.subject,
            from_email: request.params.from_email,
            from_name: request.params.from_name
        },
        async: false

    }, {
        success: function (httpResponse) {
            console.log(httpResponse);
            response.success(httpResponse);
        },
        error: function (httpResponse) {
            console.error(httpResponse);
            response.error(httpResponse);
        }
    });
});
