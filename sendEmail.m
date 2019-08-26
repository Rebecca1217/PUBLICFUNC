function sendEmail(varargin)
% send email use 163 mailbox
% 参数顺序：(toAddress, password, subject, content, attachment)
% 主题和正文必须输入，附件可选可不选
sendAddress = '13146308117@163.com';
password = 'SQ1217';

if nargin < 3
    error('toAddress, subject and content have to be specified!')
else
    toAddress = varargin{1};
%     password = varargin{2};
    subject = varargin{2};
    content = varargin{3};
    if nargin == 4
        attachment = varargin{4};
    end
end

setpref('Internet', 'E_mail', sendAddress);
setpref('Internet', 'SMTP_Server', 'smtp.163.com');%SMTP服务器
setpref('Internet', 'SMTP_Username', sendAddress);
setpref('Internet', 'SMTP_Password', password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');

if nargin == 4
    sendmail(toAddress, subject, content, attachment);
else
    sendmail(toAddress, subject, content);
end

end

