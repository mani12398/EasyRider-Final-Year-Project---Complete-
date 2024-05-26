String gethtmltemplate() {
  var template = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verify your account</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 0;
      color: #333;
      background-color: #f7f7f7;
    }

    .container {
      width: 600px;
      margin: 50px auto;
      padding: 20px;
      background-color: #fff;
      border-radius: 10px;
      box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
    }

    .header {
      background-color: #ff9f43;
      color: #fff;
      padding: 20px;
      text-align: center;
      font-size: 24px;
      border-radius: 10px 10px 0 0;
    }

    .content {
      padding: 20px;
      line-height: 1.6;
    }

    .otp {
      background-color: #3498db;
      padding: 15px;
      font-size: 26px;
      font-weight: bold;
      text-align: center;
      border-radius: 10px;
      margin: 20px 0;
      color: #fff;
      box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
    }

    .footer {
      text-align: center;
      padding: 10px;
      font-size: 14px;
      color: #777;
      border-top: 1px solid #ddd;
      border-radius: 0 0 10px 10px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      Verify your account for {{app_name}}
    </div>
    <div class="content">
      <p>Thank you for choosing {{app_name}}!</p>
      <p>Please use the following one-time password (OTP) to verify your account:</p>
      <p class="otp">{{otp}}</p>
    </div>
    <div class="footer">
      &copy; {{app_name}} 2023
    </div>
  </div>
</body>
</html>
''';
  return template;
}
