from django.shortcuts import render
from django.views.generic import ListView, CreateView, UpdateView, DeleteView
from django.views.generic.detail import DetailView
from django.urls import reverse_lazy
from .models import TodoModel
from django import forms


class TodoList(ListView):
    template_name = 'todo/list.html'  # 左側は必ずこのスペル
    model = TodoModel

class TodoDetail(DetailView):
    template_name = 'todo/detail.html'  # templates/todo/detail.html のパス
    model = TodoModel

class TodoCreate(CreateView):
    template_name = 'todo/create.html'
    model = TodoModel
    fields = ('title','memo','priority','duedate')
    success_url = reverse_lazy('list')

    # ↓ これがあることで、カレンダーが正しく機能する。
    def get_form(self):
        form = super().get_form()
        form.fields['duedate'].widget = forms.DateInput(attrs={'type': 'date'})
        return form


class TodoUpdate(UpdateView):
    template_name = 'todo/update.html'
    model = TodoModel
    fields = ('title','memo','priority','duedate')
    success_url = reverse_lazy('list')

   # ↓ TodoCreateにあるこれと同じものを、UpdateViewにも追加する。
    def get_form(self):
        form = super().get_form()
        form.fields['duedate'].widget = forms.DateInput(attrs={'type': 'date'})
        return form


class TodoDelete(DeleteView):
    template_name = 'todo/delete.html'
    model = TodoModel
    success_url = reverse_lazy('list')

# Create your views here.
