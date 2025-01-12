import csv
import random
import string
from datetime import datetime, timedelta
from faker import Faker
fake = Faker('pt_BR')

# Função para gerar nomes mais realistas
def generate_realistic_name():
    first_names = ["Lucas", "Maria", "João", "Ana", "Pedro", "Julia", "Gabriel", "Clara", "Rafael", "Sophia"]
    last_names = ["Silva", "Souza", "Costa", "Oliveira", "Pereira", "Santos", "Ferreira", "Lima", "Carvalho", "Almeida"]
    return f"{random.choice(first_names)} {random.choice(last_names)}"

# Função para gerar emails mais realistas
def generate_realistic_email(existing_emails, name):
    while True:
        username = name.split(" ")[0].lower() + ''.join(random.choices(string.digits, k=3))
        email = f"{username}@example.com"
        if email not in existing_emails:
            existing_emails.add(email)
            return email

# Função para gerar datas aleatórias
def random_date(start, end):
    delta = end - start
    random_days = random.randint(0, delta.days)
    return start + timedelta(days=random_days)

# Gerar dados para tb_usuario
usuarios = []
email_set = set()
for i in range(1, 101):
    name = generate_realistic_name()
    usuarios.append({
        'nome': name,
        'email': generate_realistic_email(email_set, name),
        'senha': ''.join(random.choices(string.ascii_letters + string.digits, k=10)),
        'data_criacao': datetime.now() - timedelta(days=random.randint(0, 1000))
    })

# Gerar dados para tb_conexao
conexoes = []
for i in range(1, 201):
    while True:
        id_seguidor = random.randint(1, 100)
        id_seguido = random.randint(1, 100)
        if id_seguidor != id_seguido and not any(c['id_seguidor'] == id_seguidor and c['id_seguido'] == id_seguido for c in conexoes):
            conexoes.append({
                'id_seguidor': id_seguidor,
                'id_seguido': id_seguido,
                'data_conexao': datetime.now() - timedelta(days=random.randint(0, 1000))
            })
            break

# Gerar dados para tb_conteudo
conteudos = []
id_textos_disponiveis = list(range(1, 101))
random.shuffle(id_textos_disponiveis)
proximo_id_texto = 101  # Variável para controlar o próximo ID

# Lista de palavras para gerar títulos
palavras_titulo = ["Tecnologia", "Inovação", "Ciência", "Descobertas", "Mercado", "Futuro", 
                  "Impacto", "Transformação", "Digital", "Soluções", "Crescimento", 
                  "Desenvolvimento", "Oportunidades", "Estudos", "Resultados", "Análise",
                  "Tendências", "Internet", "Redes", "Inteligência Artificial"]

for i in range(1, 101):
    if id_textos_disponiveis:
        id_texto = id_textos_disponiveis.pop()
    else:
        id_texto = proximo_id_texto
        proximo_id_texto += 1

    # Gerar título com no máximo 50 caracteres (Opção 1)
    titulo = " ".join(random.sample(palavras_titulo, random.randint(2, 5)))
    if len(titulo) > 50:
        titulo = titulo[:47]

    # # Gerar título com tamanho fixo de 50 caracteres (Opção 2)
    # titulo = " ".join(random.sample(palavras_titulo, random.randint(2, 5)))
    # titulo = (titulo + " " * 50)[:50]  # Completa com espaços e trunca

    conteudos.append({
        'titulo': titulo,
        'data_criacao': datetime.now() - timedelta(days=random.randint(0, 1000)),
        'id_texto': id_texto,
        'id_video': i if i % 3 == 0 else None,
        'id_img': i if i % 4 == 0 else None,
        'id_link': i if i % 5 == 0 else None
    })
    
# Gerar dados para tb_publicacao
publicacoes = []
for i in range(1, 101):
    publicacoes.append({
        'id_conteudo': random.randint(1, 100),
        'data_publicacao': datetime.now() - timedelta(days=random.randint(0, 1000))
    })

# Gerar dados para tb_usuario_publicacao
usuario_publicacao = []
for i in range(1, 201):  # Aumentado para 200 registros
    id_publicacao = random.randint(1, 100)
    coautores = random.sample(range(1, 101), random.randint(1, 3))
    for id_usuario in coautores:
        if not any(up['id_usuario'] == id_usuario and up['id_publicacao'] == id_publicacao for up in usuario_publicacao):
            usuario_publicacao.append({
                'id_usuario': id_usuario,
                'id_publicacao': id_publicacao,
                'papel': random.choice(['Autor', 'Coautor']),
                'data_associacao': datetime.now() - timedelta(days=random.randint(0, 1000))
            })

# Gerar dados para tb_texto, tb_img, tb_video e tb_link
textos = [{'conteudo_texto': fake.paragraph(nb_sentences=5, variable_nb_sentences=True)} for i in range(1, 101)]  # Aumentado para 100 registros
imgs = [{'url_img': f"https://example.com/img{i}.jpg"} for i in range(1, 101)]  # Aumentado para 100 registros
videos = [{'url_video': f"https://example.com/video{i}.mp4"} for i in range(1, 101)]  # Aumentado para 100 registros
links = [{'url_link': f"https://example.com/link{i}"} for i in range(1, 101)]  # Aumentado para 100 registros

# Função para salvar os dados em CSV
def save_to_csv(filename, fieldnames, data):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data)

# Salvar os CSVs
save_to_csv('tb_usuario.csv', ['nome', 'email', 'senha', 'data_criacao'], usuarios)
save_to_csv('tb_conexao.csv', ['id_seguidor', 'id_seguido', 'data_conexao'], conexoes)
save_to_csv('tb_conteudo.csv', ['titulo', 'data_criacao', 'id_texto', 'id_video', 'id_img', 'id_link'], conteudos)
save_to_csv('tb_publicacao.csv', ['id_conteudo', 'data_publicacao'], publicacoes)
save_to_csv('tb_usuario_publicacao.csv', ['id_usuario', 'id_publicacao', 'papel', 'data_associacao'], usuario_publicacao)
save_to_csv('tb_texto.csv', ['conteudo_texto'], textos)
save_to_csv('tb_img.csv', ['url_img'], imgs)
save_to_csv('tb_video.csv', ['url_video'], videos)
save_to_csv('tb_link.csv', ['url_link'], links)