from django.db import models

CHOICE = (
        ('high', '高'),
        ('normal', '普通'),
        ('low', '低'),
   )

class TodoModel(models.Model):
    title = models.CharField(max_length=100)
    memo = models.TextField()
    priority = models.CharField(                # 優先度 
        max_length=50,
        choices=CHOICE,                         
        null=True
    )

    duedate = models.DateField()
    
    completed = models.BooleanField(default=False)  # ← 完了フラグ
    created_at = models.DateTimeField(auto_now_add=True)  # ← 作成日時
    
    def __str__(self):
        return self.title                      #__str__はオブジェクトの文字列（str）として表示する時に呼ばれるメソッド
                                               #selfはオブジェクト自身（この中に例えば本の題名とか出現）
                                               #return self.titleはそのオブジェクトのtitle 属性を文字列として返す