def iostat_result
  iostat =
<<-EOF
Linux 3.16.0-4-amd64 (foobar)       01/15/16        _x86_64_        (4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           2.91    0.00    0.51    0.91    0.00   95.68

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               3.22     0.40    7.02    3.91   105.66   117.36    40.81     0.18   16.02    6.11   33.82   2.71   2.96
md0               0.00     0.00   38.65    9.09   298.09    97.37    16.57     0.00    0.00    0.00    0.00   0.00   0.00

EOF

  [StringIO.new('stdin'), StringIO.new(iostat), StringIO.new('stderr')]
end
