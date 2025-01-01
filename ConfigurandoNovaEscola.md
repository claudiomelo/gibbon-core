# Passo a passo para configurar uma nova escola, logar como system admim
    1. Crie ano letivo conforme o necessario, va para "Admin" -> "School Admin"
    2. 



Va para "Admim" no menu e escolha "System Admin"
depois va em system settings
    - Alterar o logo em "Logo"
        - Relative path to site logo (400 x 100px)


O sistema é baseado em ano letivo, a escola pode ter 1 unico ano letivo no ano ou mais de um por exemplo 1 iniciando em fevereiro e terminando em julho, e outro iniciando em agosto e terminando em dezembro, seria tipo o semestre, ou seja vc pode ter ano letivo 2025-2026-1 e 2025-2026-2 e em cada um vc indica o inicio e fim.



Criar chave ssh git caso n tenha:

# Gerar chave SSH
ssh-keygen -t ed25519 -C "email@email.com"

# Iniciar o ssh-agent no background
eval "$(ssh-agent -s)"

# Adicionar a chave SSH ao agente
ssh-add ~/.ssh/id_ed25519

# Exibir a chave pública
cat ~/.ssh/id_ed25519.pub

configurar proxy reverso para subdominios no nginx (instalar o vim se no tiver):
sudo vim /etc/nginx/sites-available/seu-dominio.com

adicione o seguinte conteudo ao dominio, onde 8081 é pra onde vc quer redirecionar:
server {
    listen 80;
    server_name dormentes.escolas.conectaprefeituras.com www.dormentes.escolas.conectaprefeituras.com;

    location / {
        proxy_pass http://127.0.0.1:8080; # Redireciona para o serviço Docker na porta 8080
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

    Salve o arquivo e crie um link simbólico para ativar o site:
        sudo ln -s /etc/nginx/sites-available/dormentes.escolas.conectaprefeituras.com /etc/nginx/sites-enabled/

Teste a configuração do NGINX:
    sudo nginx -t

Reinicie o NGINX:
    sudo systemctl restart nginx



Gerar https para cada dominio e subdominio:
    Obter o Certificado SSL com Certbot
        Execute o comando abaixo para gerar o certificado:
            ```
             sudo certbot --nginx -d dormentes.escolas.conectaprefeituras.com -d www.dormentes.escolas.conectaprefeituras.com
            ```
        Siga as instruções na tela para completar o processo de geração do certificado.
        Certifique-se de que o Certbot configurou corretamente o redirecionamento HTTP para HTTPS. O arquivo de configuração final em /etc/nginx/sites-available/seu-dominio.com deve conter algo assim:

        nginx
        server {
            listen 80;
            server_name seu-dominio.com www.seu-dominio.com;
            return 301 https://$host$request_uri;
        }

        server {
            listen 443 ssl;
            server_name seu-dominio.com www.seu-dominio.com;

            ssl_certificate /etc/letsencrypt/live/seu-dominio.com/fullchain.pem;
            ssl_certificate_key /etc/letsencrypt/live/seu-dominio.com/privkey.pem;
            include /etc/letsencrypt/options-ssl-nginx.conf;
            ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

            location / {
                proxy_pass http://127.0.0.1:8081;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
            }
        }
        Reinicie o NGINX novamente:
        sudo systemctl restart nginx
        Passo 4: Configurar Renovação Automática do Certificado
        O Certbot já configura automaticamente um cron job para renovar os certificados. Para garantir que o NGINX seja recarregado após a renovação, faça um teste:
            sudo certbot renew --dry-run

        Observação sobre Docker
        Se no futuro você tiver múltiplos serviços rodando em diferentes containers, poderá configurar o NGINX para gerenciar o tráfego de diferentes subdomínios ou caminhos para os respectivos containers.

        Por exemplo:

        nginx
        Copy code
        server {
            listen 443 ssl;
            server_name api.seu-dominio.com;

            ssl_certificate /etc/letsencrypt/live/api.seu-dominio.com/fullchain.pem;
            ssl_certificate_key /etc/letsencrypt/live/api.seu-dominio.com/privkey.pem;

            location / {
                proxy_pass http://127.0.0.1:8082; # Serviço Docker na porta 8082
            }
        }

        server {
            listen 443 ssl;
            server_name app.seu-dominio.com;

            ssl_certificate /etc/letsencrypt/live/app.seu-dominio.com/fullchain.pem;
            ssl_certificate_key /etc/letsencrypt/live/app.seu-dominio.com/privkey.pem;

            location / {
                proxy_pass http://127.0.0.1:8083; # Serviço Docker na porta 8083
            }
        }




