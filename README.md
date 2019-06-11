# ISO 7064:2003 Check Digit Algorithm

## 安装

Gemfile文件：

```ruby
gem 'iso7064'
```

bundle：
```ruby
$ bundle
```

或者直接安装：

```ruby
gem install iso7064
```

## 使用

```ruby
ISO7064.new.calculate_numeric_check_digit('1000000000001', false) # expect return '10000000000011'
```

