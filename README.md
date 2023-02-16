# gpdb6_install
(last update date : 2022/02/16)
Tip : If same file is in this folder, you should choose the latest file.

------------------------------------------------------------------------------------------
1. GPDB Install SOP 사용법

(1)	[Clone or download] 버튼 클릭하여 파일 다운로드
(2)	다운로드된 zip 파일의 압축을 해제
(3)	압축 해제된 파일들(설치 가이드 문서와 README 파일을 제외) Greenplum master node에 업로드
  -	업로드 경로 : /data/staging
  -	/data filesystem에 staging 폴더 생성하여 작업
(4)	GPDB Install SOP 절차에 따라 GPDB 설치 진행
(5) SOP v1.2 변경 사항 - resource group 설정 내용 추가

------------------------------------------------------------------------------------------
1. How to use GPDB Install SOP

(1)	Click the [Clone or download] button to download the file
(2)	Extract the downloaded zip file
(3)	Upload the extracted files (excluding installation guide document and README file) to the Greenplum master node.
  -	Upload path: / data / staging
  -	work by creating staging folder in / data filesystem
(4)	Follow the GPDB Install SOP procedure to install GPDB
(5) SOP v1.2 updated - resource group setting contents added

------------------------------------------------------------------------------------------
2. remotechk 설정 및 사용법

(1) 설정
  - /home/gpadmin/remotechk 디렉토리 생성
  - shell scripts (remotechk.sh, crt_service_monitoring.sh)를 /home/gpadmin/remotechk 디렉토리에 생성
  - crt_service_monitoring.sh 파일 실행하여 dba.service_monitoring 테이블 생성
(2) 사용
  - Greenplum 점검이 필요한 경우 remotechk.sh을 수행
------------------------------------------------------------------------------------------
2. How to setup and use remotechk

(1) Setup
  - make a directory /home/gpadmin/remotechk
  - make shell scripts (remotechk.sh, crt_service_monitoring.sh) on the /home/gpadmin/remotechk path
  - run crt_service_monitoring.sh for making dba.service_monitoring table
(2) Use
  - run remotechk.sh if you want to check the Greenplum health
