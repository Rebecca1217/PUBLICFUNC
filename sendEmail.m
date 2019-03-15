function sendEmail(varargin)
% send email to myself
% 参数顺序：(toAddress, password, subject, content, attachment)
% 主题和正文必须输入，附件可选可不选

if nargin < 4
    error('toAddress, passord, subject and content have to be specified!')
else
    toAddress = varargin{1};
    password = varargin{2};
    subject = varargin{3};
    content = varargin{4};
    if nargin == 5
        attachment = varargin{5};
    end
end

setpref('Internet','E_mail',toAddress);
setpref('Internet','SMTP_Server','smtp.163.com');%SMTP服务器
setpref('Internet','SMTP_Username',toAddress);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');

if nargin == 5
    sendmail(toAddress, subject, content, attachment);
else
    sendmail(toAddress, subject, content);
end

end

