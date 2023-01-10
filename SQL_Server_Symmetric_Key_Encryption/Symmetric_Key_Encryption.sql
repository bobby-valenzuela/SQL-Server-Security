
-- SETUP - USE RELEVANT DB
 USE cooldatabase;

-- 1. Create master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'super_pass';

-- 2. Verify mkey exists
 SELECT * FROM sys.symmetric_keys

-- 3. Create Certificate (if you've just created a masterkey)
 CREATE CERTIFICATE ATestCertificate WITH SUBJECT = 'A Test Certificate';

-- 3. Create Certificate (using existing master key)
open master key decryption by password = 'MyTest!Mast3rP4ss';
	CREATE CERTIFICATE ATestCertificate WITH SUBJECT = 'A Test Certificate';
close master key;

-- 4. Verify certificate exists
 SELECT * FROM  sys.certificates

-- 5. Create Symmetric Key [Certificate-based]
CREATE SYMMETRIC KEY supersymmetrickey   
WITH ALGORITHM = AES_256  
ENCRYPTION BY CERTIFICATE ATestCertificate;  
GO

-- 5. Create Symmetric Key [Password-based]
CREATE SYMMETRIC KEY supersymmetrickeywpass
WITH ALGORITHM = AES_256  
ENCRYPTION BY PASSWORD='mycoolpassword';


-- 6. Verify new Symmetric Key exists
 SELECT * FROM sys.symmetric_keys

-- 7. Save something into DB by encrypting it [Using certificate-based symmetric key]

OPEN SYMMETRIC KEY supersymmetrickey
	DECRYPTION BY CERTIFICATE ATestCertificate

	INSERT key_testing 
	VALUES(
		EncryptByKey(key_GUID('supersymmetrickey'), 'pleaseencryptme' )
   )

CLOSE SYMMETRIC KEY supersymmetrickey

-- 7. Save something into DB by encrypting it [Using password-based symmetric key]

OPEN SYMMETRIC KEY supersymmetrickeywpass
	DECRYPTION BY PASSWORD='mycoolpassword'

	INSERT key_testing 
	VALUES(
		EncryptByKey(key_GUID('supersymmetrickeywpass'), 'pleaseencryptmemoar' )
	)

CLOSE SYMMETRIC KEY supersymmetrickeywpass

-- 8. Decrypt an encrypted string [Using certificate-based symmetric key]

(using varchar max but if you have an initial string length pre-defined on the plaintext to be encrypted that you can use the minimum - for example char(9))


OPEN SYMMETRIC KEY supersymmetrickey
	DECRYPTION BY CERTIFICATE ATestCertificate

	SELECT CONVERT(VARCHAR(MAX),DECRYPTBYKEY(encpass)) FROM key_testing WHERE id='3'

CLOSE SYMMETRIC KEY supersymmetrickey



-- 8. Decrypt an encrypted string [Using password-based symmetric key]


OPEN SYMMETRIC KEY supersymmetrickeywpass
	DECRYPTION BY PASSWORD='mycoolpassword'

	SELECT CONVERT(VARCHAR(MAX),DECRYPTBYKEY(encpass))
	FROM key_testing WHERE id='5'

CLOSE SYMMETRIC KEY supersymmetrickeywpass

