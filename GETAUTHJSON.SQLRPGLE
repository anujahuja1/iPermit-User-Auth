**free
ctl-opt dftactgrp(*no) actgrp(*caller) option(*srcstmt:*nodebugio);

dcl-pi *n;
    pRequestXml varchar(5000) const;
    pResponseJson varchar(5000);
end-pi;

dcl-ds UserAuthorityRequest qualified inz;
    UserId varchar(20);
end-ds;

dcl-s requestUserId varchar(20);
dcl-s authLevel int(10) inz(0);
dcl-s authName varchar(50);
dcl-s status varchar(20) inz('SUCCESS');

dcl-s canView varchar(5);
dcl-s canUpdate varchar(5);
dcl-s canAdd varchar(5);
dcl-s canEdit varchar(5);
dcl-s canDelete varchar(5);
dcl-s canManageUsers varchar(5);

exec sql
    set option commit = *none;

monitor;
    xml-into UserAuthorityRequest
        %xml(pRequestXml : 'doc=string case=any allowmissing=yes allowextra=yes');
on-error;
    pResponseJson =
        '{' +
            '"status":"ERROR",' +
            '"message":"Invalid XML request format"' +
        '}';

    *inlr = *on;
    return;
endmon;

requestUserId = %trim(UserAuthorityRequest.UserId);

if requestUserId = '';
    pResponseJson =
        '{' +
            '"status":"ERROR",' +
            '"message":"UserId is required"' +
        '}';

    *inlr = *on;
    return;
endif;

exec sql
    select USER_AUTHORITY
    into :authLevel
    from AUTHLIB.USER_AUTHORITY
    where upper(USER_ID) = upper(:requestUserId)
    fetch first 1 row only;

if sqlcode = 100;
    authLevel = 0;
    status = 'NOT_FOUND';
elseif sqlcode < 0;
    pResponseJson =
        '{' +
            '"status":"ERROR",' +
            '"message":"Database error while checking user authority",' +
            '"sqlCode":' + %char(sqlcode) +
        '}';

    *inlr = *on;
    return;
endif;

select;
when authLevel = 0;
    authName = 'No Authority';
    canView = 'false';
    canUpdate = 'false';
    canAdd = 'false';
    canEdit = 'false';
    canDelete = 'false';
    canManageUsers = 'false';

when authLevel = 1;
    authName = 'Display Only';
    canView = 'true';
    canUpdate = 'false';
    canAdd = 'false';
    canEdit = 'false';
    canDelete = 'false';
    canManageUsers = 'false';

when authLevel = 2;
    authName = 'Update Only';
    canView = 'true';
    canUpdate = 'true';
    canAdd = 'false';
    canEdit = 'true';
    canDelete = 'false';
    canManageUsers = 'false';

when authLevel = 3;
    authName = 'Add Edit Delete';
    canView = 'true';
    canUpdate = 'true';
    canAdd = 'true';
    canEdit = 'true';
    canDelete = 'true';
    canManageUsers = 'false';

when authLevel = 4;
    authName = 'Super User';
    canView = 'true';
    canUpdate = 'true';
    canAdd = 'true';
    canEdit = 'true';
    canDelete = 'true';
    canManageUsers = 'true';

other;
    authLevel = 0;
    authName = 'No Authority';
    canView = 'false';
    canUpdate = 'false';
    canAdd = 'false';
    canEdit = 'false';
    canDelete = 'false';
    canManageUsers = 'false';
endsl;

pResponseJson =
    '{' +
        '"status":"' + %trim(status) + '",' +
        '"userId":"' + %trim(requestUserId) + '",' +
        '"authorityLevel":' + %char(authLevel) + ',' +
        '"authorityName":"' + %trim(authName) + '",' +
        '"permissions":{' +
            '"canView":' + canView + ',' +
            '"canUpdate":' + canUpdate + ',' +
            '"canAdd":' + canAdd + ',' +
            '"canEdit":' + canEdit + ',' +
            '"canDelete":' + canDelete + ',' +
            '"canManageUsers":' + canManageUsers +
        '}' +
    '}';

*inlr = *on;
return;