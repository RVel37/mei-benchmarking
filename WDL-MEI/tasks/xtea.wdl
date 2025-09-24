version 1.0

task xtea {
  input {
    File bam
    File bai
    File refGenomeBwaTar
    String dockerXtea
  }

  # dynamic instance
  Int disk_gb = ceil( 2* (size(bam, "GiB") + size(refGenomeBwaTar, "GiB")) ) + 2
  String mem = "32 GB"
  Int threads = 16
  Int cpu = (threads)/2

    command <<<

        WDL_ROOT=$PWD

		

	>>>


}