* 本工程实现了多通道NTT中PE=2,4,8,16,L=1-8的配置，完全实现NTT，INTT,PWM0，PWM1
* 实现频率为接近300MHz（P=2，L=6）。
* 上述测试均已经通过
* NTT/INTT: 7*N//(2P)+L+3 cc
* PWM0/PWM1： N//P+L+3 cc

report_utilization -hierarchical  -hierarchical_depth 1 -file "D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/Resource_table/Zq_resource_P16L2.xlsx"