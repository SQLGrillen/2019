/*============================================================================
	File:		0031_demo_mimigration.sql

	Summary:    This script does the backups to demonstrate SQL Managed
                Instance online migration

				THIS SCRIPT IS PART OF THE TRACK: Ready for take-off
				                                  How to get your databases
												  into the cloud"

	Date:		June 2019

	SQL Server Version: 2008 / 2012 / 2014 / 2016 / 2017
------------------------------------------------------------------------------
	Written by Andre Essing, Microsoft Deutschland GmbH

	This script is intended only as a supplement to demos and lectures
	given by Andre Essing.  
  
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
============================================================================*/

-- ----------------------------------------------------------------------------
-- CREATE INITIAL DATABASE BACKUP
-- ----------------------------------------------------------------------------
BACKUP DATABASE [###DATRBASE_NAME###]
TO DISK = 'F:\Migration\###DATRBASE_NAME###-FULL.bak'
WITH CHECKSUM;


-- ----------------------------------------------------------------------------
-- CREATE TRANSACTION LOG BACKUP
-- ----------------------------------------------------------------------------
BACKUP Log [###DATRBASE_NAME###]
TO DISK = 'F:\Migration\###DATRBASE_NAME###-TLOG-01.trn'
WITH CHECKSUM;

BACKUP Log [###DATRBASE_NAME###]
TO DISK = 'F:\Migration\###DATRBASE_NAME###-TLOG-02.trn'
WITH CHECKSUM;

BACKUP Log [###DATRBASE_NAME###]
TO DISK = 'F:\Migration\###DATRBASE_NAME###-TLOG-03.trn'
WITH CHECKSUM;


-- ----------------------------------------------------------------------------
-- CREATE TAILLOG BACKUP (LAST TLOG BACKUP BEFORE CUTOVER)
-- ----------------------------------------------------------------------------
BACKUP Log [###DATRBASE_NAME###]
TO DISK = 'F:\Migration\###DATRBASE_NAME###-TLOG-Tail.trn'
WITH CHECKSUM;


-- ============================================================================
-- EOF