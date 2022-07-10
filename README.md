# This is de documentation of my implementation of this challenge

First of all, I've never used Ruby and that's the first time I do something with it. Ruby's syntax is pretty straight-forward so I've managed to solve the challenge in one day of studies, like some readings I read said: it's a conversational language; coding in Ruby feels like speaking to the computer. I was relutant to learn Ruby but now I really enjoy it.

## My thoughts about the implementation

- **TDD is awesome**: defining what to expect and coding based on this expectations are simply awesome! It grants code stability and prevents bugs. Also makes coding faster.
- **OOP**: this is the first time I code using OOP, the way to think the code is a lot different than C (for example).
- **Pix key types**: I used the types' regex to validate the keys but the provided URL is not well formatted to display the email regex so I've found a link to the [email standard](https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address) in a pdf version of DICT API docs.
- **Exceptions**: based on the tests, a new instance of PixKey is created even if the key is invalid. Maybe there is something I don't know about OOP but my approach would be to raise exceptions when something is wrong.

---

When I was writing the line above I tough "well, maybe theses validations could be in a parent class and the PixKey inherit its methods and @type attribute after the validations" and I did refactor the code at least 3 times and I still wasn't satisfied.
The "magic strings" as types were driving me crazy too. That's when I started to think about creating a constant defining every PixKey type. While I was writing the array of strings I thought maybe would be good to store the validations with the types... and then boom. Everything was good. After days refactoring the code over and over I was finally pleased with it, except the types methods. So after some research I implemented the methods dynamically.

At this moment I think the code is almost ready to be delivered. Thinking about the validations: two classes were created - one to validate a phone and the other to validate cpf and cnpj. This classes are off of the PixKey class because they can evaluate any input from anywhere and could be used in any other scope. Some general validations could take place in the code too.......... well let's refactor the code one more time.
For now it only checks if the new_key is a String. Following this structure, any new validation could be implemented, like checking if the new_key is already in use. (Maybe this kind of validation could be done to @key - between the steps 2 and 3 below)

The final initialize flow is as follows:
1. **Validate the input (new_key)** - checks if the input is a String
   - If the input is invalid, the @key is an empty string and the object is invalid with @type 'error'
2. **Set the object attribute @key to new_key.strip.freeze** - allows the input string to have blank spaces before and after the value
3. **Runs the types validations** - it sets the @type with the first type match while running the validations (at this moment there aren't any possible string to match more than one type validation)
   - If the @key is invalid, it stays as it is and the object is invalid with @type 'error'. This approach was meant so if it is invalid with a key, then the key didn't pass the validations but if the key is empty, the input was invalid.

## What I have learned so far

**I just can't believe how much I've learned with this project.** Since Ruby basics to OOP... here is a list:
- Ruby basic syntax
- Ruby scopes:
  - Class
  - Object
  - Metaclass
- OOP:
  - How to abstract an idea to be implemented with OOP
  - Differences in public, private and protected methods
  - Inheritance
- TDD
- Document the code using comments
  - I didn't like it at first but now I think it's good if they are not too much
- Ruby lambdas and Procs differences and how to store then in a variable

## That's all folks. I am really happy on how it ended.
A big thanks to the Husky team for this project. I am really amazed by Ruby and will try to do some Rails project right now.


## The original README is below
---



# Husky Academy

Olá seja bem-vindo(a) ao nosso teste técnico.

## Escopo

O desafio consiste em fazer a implementação de um objeto capaz de representar uma chave PIX usando a [linguagem Ruby](https://www.ruby-lang.org/en/about/).

Para isso você precisará ler a especificação oficial sobre os diferentes tipos de chaves no [DICT API](https://www.bcb.gov.br/content/estabilidadefinanceira/pix/API-DICT.html#tag/Key) e usar esse conhecimento para fazer os testes do arquivo `pix_key/spec/pix_key_spec.rb` passarem.

### Critérios de avaliação

O teste foi pensando para avaliar os seguintes atributos: clareza, qualidade e eficiência do código. Por conta disso, tente entregar algo que atenda a esses critérios.

## Preparando ambiente de dev

1. Instale o [Ruby `3.1.2`](https://www.ruby-lang.org/en/documentation/installation/).
2. Faça um clone deste repositório: `git clone git@github.com:husky-misc/husky-academy.git`
3. Acesse a pasta `pix_key`.
4. Execute `bin/setup`.

## Executando os testes unitários

1. Acesse a pasta `pix_key`.
2. Execute `bin/rake`.

## Sobre a suite de testes

Os testes foram escritos usando `Rspec`. Caso não conheça a ferramenta, acesse a [documentação oficial](https://relishapp.com/rspec/) ou procure por outros tutorias.

**Observação:** O `Rspec` tem quatro módulos: `rspec-core`, `rspec-expectations`, `rspec-mocks` e `rspec-rails`. Apenas os dois primeiros são necessários para entender os testes.

## Submetendo o seu teste para avaliação

1. Preencha o `me.json` com os seus dados.
2. Garanta que a sua branch local `main` contenha seu último commit.
3. Execute o comando `ruby prepare_to_submit.rb`
4. Faça upload do arquivo com final `.bundle` nesse form: [https://forms.gle/2Bwqm9G3Mzv3nUaD7](https://forms.gle/2Bwqm9G3Mzv3nUaD7).
5. Boa sorte! o/

### Atenção:

1. Não faça fork, nem torne o seu repositório público.
   > O __*Husky Academy*__ tem como objetivo capacitar as pessoas durante o processo seletivo, então, por favor, **não compartilhe seu código**. Permita que cada participante viva sua própria experiência de crescimento e aprendizagem.
2. Tenha certeza que o código está executável (sem erros de sintaxe) e que todos os testes estão passando.
3. Altere apenas os arquivos `pix_key/lib/pix_key.rb` e o `me.json`.
4. **Apenas um upload será permitido**. Caso contrário, há o risco de avaliarmos a versão incorreta do seu código.
