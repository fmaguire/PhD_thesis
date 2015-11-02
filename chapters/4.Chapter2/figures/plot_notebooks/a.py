#!/usr/bin/env python

import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import random


sns.set(style="darkgrid")
sns.set_context("paper")

def seek_sample(filename, n=10000):
    sample = []
    with open(filename, 'rb') as fh:
        fh.seek(0, 2)
        filesize = fh.tell()
        random_set = np.sort(np.random.randint(filesize, size=n))

        for loc in random_set:
            fh.seek(loc)
            fh.readline()

            sample.append(float(fh.readline()))

    return np.array(sample)

d2_2=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_DARK2_2_ATCACG_L002_R1_001.fastq")
d2_3=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_DARK2_3_TTAGGC_L002_R1_001.fastq")
d2_6=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_DARK2_6_CTTGTA_L002_R1_001.fastq")
d2_7=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_DARK2_7_GATCAG_L002_R1_001.fastq")
d2_8=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_DARK2_8_TAGCTT_L002_R1_001.fastq")
d1_2=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_dark_2_TAGCTT_L001_R1_001.fastq")
d1_3=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_dark_3_GGCTAC_L001_R1_001.fastq")
d1_5=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_dark_5_CTTGTA_L001_R1_001.fastq")
l1_9=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_light_9_ATGTCA_L001_R1_001.fastq")
l1_10=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_light_10_CCGTCC_L001_R1_001.fastq")
l1_11=seek_sample("/data/sequencing_projects/single_cell_transcriptomes/Pb_light_11_GTCCGC_L001_R1_001.fastq")
b1=seek_sample('bulk1_r1_gc.txt')
b2=seek_sample('bulk2_r1_gc.txt')


#d2_2=parse_dist("Pb_DARK2_2_ATCACG_L002_R1_001.fastq")
fig = plt.figure(figsize=(8,10))
plt.suptitle("Kernel Density Estimates of Read GC Proportion", size=14)
ax1 = fig.add_subplot(421)
ax1.xaxis.set_major_formatter(plt.NullFormatter())
ax2 = fig.add_subplot(422)
ax2.xaxis.set_major_formatter(plt.NullFormatter())
ax2.yaxis.set_major_formatter(plt.NullFormatter())
ax3 = fig.add_subplot(423)
ax4 = fig.add_subplot(424)
ax4.yaxis.set_major_formatter(plt.NullFormatter())

fig.subplots_adjust(left=None, bottom=None, right=None, top=None, wspace=0.1, hspace=0.3)



sns.kdeplot(d1_2, ax=ax1, label='Dark1-2').set(xlim=(0, 1), ylim=(0, 9), ylabel="Density", title="Dark 1 Libraries")
sns.kdeplot(d1_3, ax=ax1, label='Dark1-3').set(xlim=(0, 1), ylim=(0, 9), ylabel="Density", title="Dark 1 Libraries")
sns.kdeplot(d1_5, ax=ax1, label='Dark1-5').set(xlim=(0, 1), ylim=(0, 9), ylabel="Density", title="Dark 1 Libraries")
handles, labels = ax1.get_legend_handles_labels()
ax1.legend(frameon=True)

#for i in [d2_2, d2_3, d2_6, d2_7, d2_8]:
#    sns.kdeplot(i, ax=ax2).set(xlim=(0, 1), ylim=(0, 9), title="Dark 2 Libraries")

sns.kdeplot(d2_2, ax=ax2, label='Dark2-2').set(xlim=(0, 1), ylim=(0, 9), title="Dark 2 Libraries")
sns.kdeplot(d2_3, ax=ax2, label='Dark2-3').set(xlim=(0, 1), ylim=(0, 9), title="Dark 2 Libraries")
sns.kdeplot(d2_6, ax=ax2, label='Dark2-6').set(xlim=(0, 1), ylim=(0, 9), title="Dark 2 Libraries")
sns.kdeplot(d2_7, ax=ax2, label='Dark2-7').set(xlim=(0, 1), ylim=(0, 9), title="Dark 2 Libraries")
sns.kdeplot(d2_8, ax=ax2, label='Dark2-8').set(xlim=(0, 1), ylim=(0, 9), title="Dark 2 Libraries")
handles, labels = ax2.get_legend_handles_labels()
ax2.legend(frameon=True)


#for i in [l1_9, l1_10, l1_11]:
#    sns.kdeplot(i, ax=ax3).set(xlim=(0, 1), ylim=(0, 9), xlabel="Read Mean GC Proportion",  ylabel="Density", title="Light 1 Libraries")
sns.kdeplot(l1_9, ax=ax3, label="Light1-9").set(xlim=(0, 1), ylim=(0, 9), xlabel="Read Mean GC Proportion",  ylabel="Density", title="Light 1 Libraries")
sns.kdeplot(l1_10, ax=ax3, label="Light1-10").set(xlim=(0, 1), ylim=(0, 9), xlabel="Read Mean GC Proportion",  ylabel="Density", title="Light 1 Libraries")
sns.kdeplot(l1_11, ax=ax3, label="Light1-11").set(xlim=(0, 1), ylim=(0, 9), xlabel="Read Mean GC Proportion",  ylabel="Density", title="Light 1 Libraries")
ax3.legend(frameon=True)


sns.kdeplot(b1, ax=ax4, label="Bulk1").set(xlim=(0, 1), ylim=(0, 9), xlabel="Read Mean GC Proportion",  ylabel="Density", title="Trimmed Bulk Libraries")
sns.kdeplot(b2, ax=ax4, label="Bulk2").set(xlim=(0, 1), ylim=(0, 9), xlabel="Read Mean GC Proportion",  ylabel="Density", title="Trimmed Bulk Libraries")
ax4.legend(frameon=True)
fig.savefig("raw_lib_gc_prop.svg")

