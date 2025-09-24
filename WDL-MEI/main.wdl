version 1.0

import "tasks/pairBamIdxs.wdl" as pairBamIdxs
import "tasks/scramble.wdl" as scramble
import "tasks/melt.wdl" as melt
import "tasks/deepMei.wdl" as deepMei
import "tasks/mobster.wdl" as mobster

workflow main {
    input {
        Array[File] bams
        Array[File] bais
        File refGenomeBwaTar
        String dockerSamtools
        String dockerScramble
        String dockerMelt
        String dockerDeepMei
        String dockerMobster
        String dockerMobVcf
    }

    scatter (input_bam in bams) {
        call pairBamIdxs.pairBamIdxs as pb {
            input:
            bam=input_bam,
            bais=bais,
            dockerSamtools=dockerSamtools
        }

        call scramble.scramble {
            input:
            bam=pb.paired_bam, 
            bai=pb.bai,
            refGenomeBwaTar=refGenomeBwaTar,
            dockerScramble=dockerScramble
        }

        call melt.melt {
            input:
            bam=pb.paired_bam, 
            bai=pb.bai,
            refGenomeBwaTar=refGenomeBwaTar,
            dockerMelt=dockerMelt
        }

        # call deepMei.deepMei {
        #     input:
        #     bam=pb.paired_bam, 
        #     bai=pb.bai,
        #     refGenomeBwaTar=refGenomeBwaTar,
        #     dockerDeepMei=dockerDeepMei
        # }

        call mobster.mobster as mob {
            input:
            bam=pb.paired_bam,
            bai=pb.bai,
            dockerMobster=dockerMobster
        }

        call mobster.mobVcf{
            input:
            txt=mob.txt
            dockerMobVcf=dockerMobVcf
        }

    }

    output {
        Array[File?] scramble_vcfs = scramble.vcf
        Array[File?] scramble_clusters = scramble.clusters
        Array[File?] melt_alu_vcfs = melt.alu_vcf
        Array[File?] melt_line1_vcfs = melt.line1_vcf
        Array[File?] melt_sva_vcfs = melt.sva_vcf
        # Array[File?] deepmei_vcfs = deepMei.vcf
        Array[File?] mobster_txts = mob.txt
        Array[File?] mobster_vcfs = mobVcf.vcf
    }
}