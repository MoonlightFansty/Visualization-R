add_regulate <- function(data, log2FC_name = "log2FoldChange",
                         fdr_name = "padj",
                         log2FC = 1, fdr = 0.05){
  colnames(data)[colnames(data) == log2FC_name] <- "log2FoldChange"
  colnames(data)[colnames(data) == fdr_name] <- "padj"
  
  data$regulate <- "Normal"
  
  loc_up <- intersect(which(data$log2FoldChange > log2FC),
                      which(data$padj<fdr))
  loc_down <- intersect(which(data$log2FoldChange < (-log2FC)),
                        which(data$padj<fdr))
  
  data$regulate[loc_up] <- "Up"
  data$regulate[loc_down] <- "Down"
  return(data)
}

ggvolcano <- function(data,
                      x = "log2FoldChange", y = "padj",
                      pointSize = 1, pointShape = 21,
                      fills = c("#00AFBB","#999999","#FC4E07"),
                      colors = c("#00AFBB","#999999","#FC4E07"),
                      x_lab = NULL, y_lab = NULL,
                      legend_title = NULL, legend_position = "UL",
                      log2FC_cut = 1, FDR_cut = 0.05,
                      add_line = TRUE,
                      add_label = TRUE, label = "row",
                      label_number = 10, custom_label = NULL,
                      output = TRUE, filename = "volcano_plot"){
  
  colnames(data)[colnames(data) == x] <- "x"
  colnames(data)[colnames(data) == y] <- "y"
  colnames(data)[colnames(data) == label] <- "geneName"
  
  # 默认排序标签 or 自定义标签
  if (is.null(custom_label)) {
    if (label_number != 0) {
      data$label <- rep("",nrow(data))
      data$label[order(data$y)[1:label_number]] <- data$geneName[order(data$y)[1:label_number]]
    } else {
      data$label <- rep("",nrow(data))
    }
  } else {
    data$label <- rep("",nrow(data))
    data$label[match(custom_label, data$geneName)]<- custom_label
  }
  
  p <- ggplot(data, aes(x, -log10(y), color = regulate))
  p <- p +
    geom_point(aes(fill = regulate), size = pointSize, shape = pointShape) +
    scale_fill_manual(values=fills) +
    scale_color_manual(values=colors) +
    theme_bw() +
    theme(title = element_text(size = 15),
          text = element_text(size = 15),
          legend.background = element_blank()) +
    # 设置部分图例不显示：
    guides(fill = guide_legend(title = legend_title %||% "Regulate"),
           color = guide_legend(title = legend_title %||% "Regulate"))+
    # 修改坐标轴：
    labs(x = x_lab %||% TeX("$Log_2 \\textit{FC}$"),
         y = y_lab %||% TeX("$-Log_{10} \\textit{FDR} $"))
  
  # 添加虚线：
  if (add_line == TRUE) {
    p <- p +
      geom_vline(xintercept = c(-log2FC_cut,log2FC_cut), linetype ="dashed") +
      geom_hline(yintercept = -log10(FDR_cut), linetype ="dashed")
  }
  
  # 添加标签：
  if (add_label == TRUE) {
    p <- p +
      geom_text_repel(aes(label = label), size=3, max.overlaps = 100, key_glyph = draw_key_point)
    
  }
  
  # 图例位置：
  if (legend_position == "UL") {
    p <- p+
      theme(
        legend.position = c(0.01, 0.99),
        legend.justification = c(0, 1),
      )
  } else if (legend_position == "UR") {
    p <- p+
      theme(
        legend.position = c(0.99, 0.99),
        legend.justification = c(1, 1),
      )
  } else if (legend_position == "DL") {
    p <- p+
      theme(
        legend.position = c(0.01, 0.01),
        legend.justification = c(0, 0),
      )
  } else {
    p <- p+
      theme(
        legend.position = c(0.99, 0.01),
        legend.justification = c(1, 0),
      )
  }
  
  
  # 保存图片：
  if (output == TRUE) {
    ggsave(paste0(filename, ".pdf"), plot = p, height = 5, width = 6)
  }
  
  return(p)
}

gradual_volcano <- function(data,
                            x = "log2FoldChange", y = "padj",
                            pointSizeRange = c(0.5, 4),
                            fills = c("#39489f","#39bbec","#f9ed36","#f38466","#b81f25"),
                            colors = c("#17194e","#68bfe7","#f9ed36","#a22f27","#211f1f"),
                            x_lab = NULL, y_lab = NULL,
                            legend_title = NULL, legend_position = NULL,
                            add_line = TRUE, log2FC_cut = 1, FDR_cut = 0.05,
                            add_label = TRUE, label = "row",
                            label_number = 10, custom_label = NULL,
                            output = TRUE, filename = "volcano_plot"
){
  colnames(data)[colnames(data) == x] <- "x"
  colnames(data)[colnames(data) == y] <- "y"
  colnames(data)[colnames(data) == label] <- "geneName"
  
  # 默认排序标签 or 自定义标签
  if (is.null(custom_label)) {
    if (label_number != 0) {
      data$label <- rep("",nrow(data))
      data$label[order(data$y)[1:label_number]] <- data$geneName[order(data$y)[1:label_number]]
    } else {
      data$label <- rep("",nrow(data))
    }
  } else {
    data$label <- rep("",nrow(data))
    data$label[match(custom_label, data$geneName)]<- custom_label
  }
  
  p <- ggplot(data,aes(x, -log10(y)))
  
  p <- p +
    # 散点图:
    geom_point(aes(size=-log10(y), fill = -log10(y), color =  -log10(y)), shape = 21)+
    # 指定颜色渐变模式：
    scale_fill_gradientn(values = seq(0,1,0.2),
                         colors = fills)+
    scale_color_gradientn(values = seq(0,1,0.2),
                          colors = colors)+
    # 指定散点大小渐变模式：
    scale_size_continuous(range = pointSizeRange)+
    # 主题调整：
    theme_bw()+
    # 调整主题和图例位置：
    theme(panel.grid = element_blank(),
          legend.background = element_blank()
    )+
    # 设置部分图例不显示：
    guides(fill = guide_colourbar(title = legend_title %||% "-Log10_q-value"),
           color = "none",
           size = "none")+
    # 修改坐标轴：
    labs(x = x_lab %||% TeX("$Log_2 \\textit{FC}$"),
         y = y_lab %||% TeX("$-Log_{10} \\textit{FDR} $"))
  
  # 添加虚线：
  if (add_line == TRUE) {
    p <- p +
      geom_vline(xintercept = c(-log2FC_cut,log2FC_cut), linetype ="dashed") +
      geom_hline(yintercept = -log10(FDR_cut), linetype ="dashed")
  }
  
  # 添加标签：
  if (add_label == TRUE) {
    p <- p +
      geom_text_repel(aes(label = label, color = -log10(y)), size=3, max.overlaps = 100, key_glyph = draw_key_point)
    
  }
  
  # 图例位置：
  if (is.null(legend_position)){
    p <- p +
      theme(legend.position = c(0.01,0.7),
            legend.justification = c(0,1)
      )
  } else if (legend_position == "UL") {
    p <- p+
      theme(
        legend.position = c(0.01, 0.99),
        legend.justification = c(0, 1),
      )
  } else if (legend_position == "UR") {
    p <- p+
      theme(
        legend.position = c(0.99, 0.99),
        legend.justification = c(1, 1),
      )
  } else if (legend_position == "DL") {
    p <- p+
      theme(
        legend.position = c(0.01, 0.01),
        legend.justification = c(0, 0),
      )
  } else {
    p <- p+
      theme(
        legend.position = c(0.99, 0.01),
        legend.justification = c(1, 0),
      )
  }
  
  # 保存图片：
  if (output == TRUE) {
    ggsave(paste0(filename, ".pdf"), plot = p, height = 5, width = 6)
  }
  return(p)
}

term_volcano <- function(data, term_data,
                         x = "log2FoldChange", y = "padj",
                         normal_point_color = "#999999",
                         normal_point_size = 1,
                         deg_point_color = "black",
                         deg_point_fill = c(dendritic="#49c2c6", "ion transport."="#fbcbcc",
                                            metabolic="#eef0ac",myelin="#b1daa7",
                                            synaptic="#d0d0a0"),
                         deg_point_size = 2,
                         legend_background_fill = "#fefde2",
                         legend_title = NULL, legend_position = "UL",
                         add_line = TRUE, log2FC_cut = NULL, FDR_cut = 0.05,
                         add_label = TRUE, label = "row",
                         label_number = 10, custom_label = NULL,
                         x_lab = NULL, y_lab = NULL,
                         output = TRUE, filename = "volcano_plot"){
  
  colnames(term_data) <- c("geneName", "term")
  colnames(data)[colnames(data) == x] <- "x"
  colnames(data)[colnames(data) == y] <- "y"
  colnames(data)[colnames(data) == label] <- "geneName"
  
  # 添加GO一列：
  data$GO_term <- "others"
  term_data <- term_data[term_data$geneName %in% data$geneName,]
  data[term_data$geneName,]$GO_term <- term_data$term
  
  # 计算上调下调数目：
  Down_num <- length(which(data$y < 0.05 & data$x < 0))
  Up_num <- length(which(data$y < 0.05 & data$x > 0))
  
  # 设定原始散点颜色：
  color <- rep(normal_point_color, nrow(data))
  
  # 默认排序标签 or 自定义标签
  if (is.null(custom_label)) {
    if (label_number != 0) {
      data$label <- rep("",nrow(data))
      data$label[order(data$y)[1:label_number]] <- data$geneName[order(data$y)[1:label_number]]
    } else {
      data$label <- rep("",nrow(data))
    }
  } else {
    data$label <- rep("",nrow(data))
    data$label[match(custom_label, data$geneName)]<- custom_label
  }
  
  p <- ggplot(data[which(data$GO_term!="others"),],
              aes(x,-log10(y),fill = GO_term))+
    geom_point(data=data[which(data$GO_term=="others"),],
               aes(x,-log10(y)),
               size = normal_point_size, color=normal_point_color) +
    # 彩色散点：
    geom_point(size = deg_point_size, shape=21, color=deg_point_color) +
    scale_fill_manual(values = deg_point_fill) +
    labs(x = x_lab %||% TeX("$Log_2 \\textit{FC}$"),
         y = y_lab %||% TeX("$-Log_{10} \\textit{FDR} $"))+
    theme(title = element_text(size = 15), text = element_text(size = 15)) +
    theme_bw() +
    theme(panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),
          # 图例大框颜色：
          legend.background = element_rect(
            fill = legend_background_fill, # 填充色
            colour = "black", # 框线色
            # 线条宽度
            size = 0.2),
          # 图例符号颜色：
          legend.key = element_rect(fill = legend_background_fill),
          # 调整图例大小：
          legend.key.size = unit(12, "pt"))+
    guides(fill = guide_legend(title = legend_title %||% "GO terms"))
  
  # 添加虚线：
  if (add_line == TRUE) {
    if (is.null(log2FC_cut)) {
      p <- p +
        geom_vline(xintercept = 0, linetype ="longdash") +
        geom_hline(yintercept = -log10(FDR_cut), linetype ="longdash")
    } else {
      p <- p +
        geom_vline(xintercept = c(-log2FC_cut,log2FC_cut), linetype ="dashed") +
        geom_hline(yintercept = -log10(FDR_cut), linetype ="dashed")
    }
  }
  
  # 添加标签：
  if (add_label == TRUE) {
    p <- p +
      geom_text_repel(data = data, aes(x,-log10(y), label = label), size=3, max.overlaps = 100, key_glyph = draw_key_point)
  }
  
  # 图例位置：
  if (legend_position == "UL") {
    p <- p+
      theme(
        legend.position = c(0.01, 0.99),
        legend.justification = c(0, 1),
      )
  } else if (legend_position == "UR") {
    p <- p+
      theme(
        legend.position = c(0.99, 0.99),
        legend.justification = c(1, 1),
      )
  } else if (legend_position == "DL") {
    p <- p+
      theme(
        legend.position = c(0.01, 0.01),
        legend.justification = c(0, 0),
      )
  } else {
    p <- p+
      theme(
        legend.position = c(0.99, 0.01),
        legend.justification = c(1, 0),
      )
  }
  
  # 保存图片：
  if (output == TRUE) {
    ggsave(paste0(filename, ".pdf"), plot = p, height = 5, width = 6)
  }
  return(p)
}
