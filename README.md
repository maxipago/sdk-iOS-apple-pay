Apple Pay iOS - maxiPago! SDK
========================

Apple Pay SDK maxiPago! - Pagamentos Apple Pay em Apps iOS

## Requisitos

-   [integração maxiPago! completa, para viabilizar estornos, capturas entre outras features]
-   [XCode 9, iPhone 6 ou superior]

## Instalação

Faça o clone deste projeto. 

Efetue a configuração para seu ambiente iOS

## Inicialização

A integração com o Apple Pay requer a troca dois certificados com a maxiPago, além da criação de um Merchant ID no Apple Member Center [https://developer.apple.com]

- Merchant Identity Certificate: Responsável pela autenticação de seu merchant ID nos servidores da Apple

- Payment Provider Certificate: Responsável por auxiliar o processo de descriptrografia dos dados de pagamento tokenizados com o Apple Pay.

- O Apple Pay necessita que sua execução seja feita sob um ambiente HTTPS e que este domínio seja verificado no Apple Member Center.

A maxiPago! disponibiliza um guia de afiliação completo para o Produto Apple Pay que te auxiliará neste processo de certificação e verificação de domínio, para mais informações, contate um de nossos representantes :) 


### Setup

Para dar suporte ao Apple Pay, seu app precisa ter a função ativada nos capabilities do App.
![alt text](http://i1255.photobucket.com/albums/hh633/lramosouza/Apple%20Pay%20App%20-%20Fluxo%201_zpsizscv7eh.png)


### Fluxo Apple Pay
![alt text](http://i1255.photobucket.com/albums/hh633/lramosouza/enable%20apple%20pay_zpsdcwkgszp.png)


## Implementação

Preencher as suas informações de carrinho acumuladas, também pode-se configurar as bandeiras a serem utilizadas e o tipo de segurança: 

supportedNetworks: bandeiras que deseja dar suporte, no momento, a maxiPago! dá suporte à mastercard e visa.

merchantCapabilities: features a serem suportadas, no caso, habilitar o suporte à 3DS: supports3DS.

requiredShippingContactFields : definir quais campos deseja que o preenchimento seja obrigatório

maxipagoAdditionalPaymentData: adicionar os parâmetros adicionais da maxiPago!


- NOTE: Esta loja exemplo possui alguns logs para auxilia-lo na depuração, retire os logs antes de rodar em produção. Altere o endpoint da api da maxiPago! na classe consumidora: 
SANDBOX: https://testapi.maxipago.net/UniversalAPI/rest/EncryptedWallet/order
PRODUÇÃO: https://api.maxipago.net/UniversalAPI/rest/EncryptedWallet/order

