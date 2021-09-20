# Resposta ao desafio - estágio em Data Analytics
 Olá! Obrigado mais uma vez pela oportuidade :)
 
 Tão importante quanto o resultado é saber de onde ele veio - criei esse repositório para
 que possam dar uma olhadinha no raciocínio que elaborei enquanto escrevi meu código,
 bem como para avaliar a limpeza dele. Por uma questão de padronização de código, 
 os comentários que o acompanham estão em inglês, mas caso haja a necessidade, 
 posso disponibilizar uma tradução.
 
 Abaixo, o link da resposta:
 https://lucasketzer.shinyapps.io/data-analyst-challenge/
 
 ## Dependências do projeto
 Ah sim, dependências! É importante lembrar que você deverá ter alguns pacotes instalados para poder rodar todos os scripts em sua máquina.
 
 * RColorBrewer: Torna mais fácil lidar com cores em gráficos no R, principalmente quando precisamos de paletas.
 * extrafont: Usado para instalar a fonte Ubuntu e usá-la em temas de gráficos.
 * tidyverse: O pacote mais compreensivo para Data Science em R - inclui o ggplot2.
 * data.table: Usado para "pivotar" tabelas, isto é, transformá-las de um formato longo para comprido, ou vice-versa.
 * readxl: Direto - usado para ler pastas do excel .xlsx.
 * shiny: O shiny permite construir dashboards e interfaces de usuário com relativa facilidade - ele que foi usado para construir o site (ou quase).
 * shinydashboard: Na verdade, este foi o ator principal - ele fornece estruturas de dashboards pré-prontas! Tem papel principal no projeto.

Para que você não precise se preocupar com isso, caso não tenha estes pacotes, simplesmente rode o arquivo packages.R que se encontra nesse repositório.
 
 ## Quais arquivos temos aqui?
 
* scripts: Uma pasta que contém as respostas para cada pergunta do desafio, individualmente.

  * challenge_1.R: Apresenta o caminho percorrido até chegar aos tipos de vaga com maior custo.
  * challenge_2.R: Apresenta o caminho percorrido até chegar à receita mensal por cliente em 2020.
  * challenge_3.R: Apresenta o caminho percorrido até chegar ao lucro mensal da empresa X em 2020.
  * challenge_4.R: Apresenta o caminho percorrido até chegar à projeção do lucro mensal para 2021.
  * theme.R: Um tema para os gráficos, para padronizar sua apresentação.
  
* font: Uma pasta contendo a fonte Ubuntu, que foi usada em theme.R. Caso você já tenha ela instalada em seu ambiente R, vá até theme.R e comente a parte do código que instala as fontes:

```
#font_import(paste(wd, "/font", sep = ""))
```

* www/font.css: Um pequeno arquivo css, usado para mudar a fonte do shinydashboard.

* app.R: O script que montou o dashboard linkado acima. Basta executar o script que você poderá rodá-lo localmente. 

* data: Uma pasta contendo todos os dados do repositório original, em formato CSV. Um deles foi convertido em xlsx, por questões de enconding

* plot_data: Uma pasta contendo a versão tratada dos dados, utilizados para fazer os gráficos.

  * cat_profit_costs.csv: Custo e lucro médio por categoria de vaga.
  * cust_type_profit_costs.csv: Custo e lucro médio por categoria de cliente.
  * mean_cost_by_type.csv: Custo médio por tipo de vaga.
  * mon_rev_by_client.csv: Receita mensal por cliente.
  * monthly_profit_forecast.csv: Lucro mensal em 2020 e lucro mensal previsto para 2021.
  * monthly_profit.csv: Lucro mensal em 2020

Abaixo, uma pequena visualização da estrutura de cada uma (OBS - o X que pode estar presente nas bases se refere ao index herdado da função write.csv):

#### cat_profit_costs.csv
| Category Id | Category Name | Total Jobs  |profitOrCost | value      | 
| ---         | ---           | ---         |---          | ---        |             
| 1           | Tecnologia    | 6           |meanProfit   | 1866,42    | 

### cust_type_profit_costs.csv
| Customer Type ID | Total Customers|profitOrCost | value      | 
| ---              | ---            |---          | ---        |             
| 10               | Tecnologia     |meanProfit   | 551, 14    | 

### mean_cost_by_type.csv
| Job Type              | Mean Total Cost| 
| ---                   | ---            |             
| Analista de Help Desk | 104,85         |

### mon_rev_by_client.csv
| Customer Name | Month   | Revenue |
| ---           | ---     | ---     |    
| Cliente A     | 1       | 551,21  |

### monthly_profit_forecast.csv
| --- | Month         | Forecast or Current   | Profit  |
| --- | ---           | ---                   | ---     |    
|  1  | 1             | profit                | 1993,61 |
| --- | ---           | ---                   | ---     |
| 13  | 1             | forecastedProfit      | 2681,01 |

### monthly_profit.csv
| Month   | Profit  |
| ---     | ---     |    
| 1       | 1993,61 |
