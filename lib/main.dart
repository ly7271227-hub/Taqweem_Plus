import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TaqweemApp());

const navy = Color(0xFF101B35);
const gold = Color(0xFFE8B85B);
const bg = Color(0xFFF4F6FA);

class TaqweemApp extends StatelessWidget {
  const TaqweemApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تقويم بلس',
      theme: ThemeData(
        useMaterial3: true, scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy),
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white, centerTitle: true),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int tab = 0;
  final pages = const [DashboardPage(), ToolsPage(), GamesPage(), NotesPage()];
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('تقويم بلس ✦', style: TextStyle(fontWeight: FontWeight.bold))),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'الأدوات'),
          NavigationDestination(icon: Icon(Icons.sports_esports), label: 'الألعاب'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'ملاحظاتي'),
        ],
      ),
    ),
  );
}

String gDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
String hDate(DateTime d) {
  final h = HijriCalendar.fromDate(d);
  return h.toFormat('dd MMMM yyyy');
}
String weekday(DateTime d) => const ['الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'][d.weekday-1];

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [navy, Color(0xFF263D68)]), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('يومك بالتاريخين', style: TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 12),
          Text(gDate(now), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(hDate(now), style: const TextStyle(color: gold, fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('${weekday(now)} • ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}', style: const TextStyle(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 18),
      const Text('اختصارات سريعة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: navy)),
      const SizedBox(height: 10),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.35,
        children: [
          quick(context, 'تحويل التاريخ', Icons.sync_alt, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DateConverterPage()))),
          quick(context, 'احسب عمرك', Icons.cake_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgePage()))),
          quick(context, 'فرق الأيام', Icons.date_range, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaysPage()))),
          quick(context, 'العد التنازلي', Icons.hourglass_bottom, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CountdownPage()))),
        ]),
      const SizedBox(height: 18),
      const Text('مناسبات ومعلومات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: navy)),
      const SizedBox(height: 8),
      const InfoTile(icon: Icons.info_outline, title: 'تنبيه التاريخ الهجري', subtitle: 'قد يختلف التاريخ الهجري يومًا حسب الرؤية الشرعية والبلد.'),
      const InfoTile(icon: Icons.lightbulb_outline, title: 'فكرة اليوم', subtitle: 'اكتب هدفًا صغيرًا اليوم، وحدد له وقتًا واضحًا.'),
    ]);
  }
  Widget quick(BuildContext c, String title, IconData icon, VoidCallback onTap) => InkWell(onTap:onTap, borderRadius: BorderRadius.circular(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E9F0))), child: Row(children:[const SizedBox(width:10), Icon(icon,color:gold), const SizedBox(width:8), Flexible(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w600,color:navy)))])));
}

class InfoTile extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const InfoTile({super.key, required this.icon, required this.title, required this.subtitle});
  @override Widget build(BuildContext context) => Card(color:Colors.white,elevation:0,child:ListTile(leading:Icon(icon,color:gold),title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(subtitle)));
}

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});
  @override Widget build(BuildContext context) {
    final items = <ToolItem>[
      ToolItem('محول ميلادي/هجري','تحويل التاريخ بين التقويمين',Icons.sync_alt, const DateConverterPage()),
      ToolItem('حاسبة العمر','العمر بالسنوات والأشهر والأيام',Icons.cake, const AgePage()),
      ToolItem('فرق الأيام','احسب المدة بين تاريخين',Icons.date_range, const DaysPage()),
      ToolItem('العد التنازلي','كم بقي على مناسبة؟',Icons.hourglass_bottom, const CountdownPage()),
      ToolItem('إضافة مدة لتاريخ','أضف أيامًا أو أسابيع أو أشهرًا',Icons.add_circle_outline, const AddDurationPage()),
      ToolItem('حاسبة بسيطة','عمليات الجمع والطرح والضرب والقسمة',Icons.calculate, const CalculatorPage()),
      ToolItem('مؤقت التركيز','جلسة تركيز لمدة دقيقة',Icons.timer, const FocusPage()),
      ToolItem('معلومة التقويم','تعرف على التقويمين',Icons.menu_book, const AboutCalendarPage()),
      ToolItem('مفكرة اليوم','سجل أفكارك ومواعيدك',Icons.note_alt, const NotesPage()),
      ToolItem('قائمة المهام','رتب أهم ما تريد إنجازه',Icons.checklist, const TasksPage()),
    ];
    final extras = const [
      ['منبه المناسبات','تذكير محلي يحتاج تفعيل الإشعارات',Icons.notifications_active],
      ['مواقيت الصلاة','تحتاج تحديد المدينة ومصدر مواقيت موثوق',Icons.mosque],
      ['اتجاه القبلة','تحتاج صلاحية الموقع والبوصلة',Icons.explore],
      ['حالة الطقس','تحتاج اتصالًا بمصدر طقس',Icons.cloud],
      ['تحويل وحدات','كيلومتر ومتر ووزن وحرارة',Icons.straighten],
      ['حساب النسبة المئوية','احسب الخصم والزيادة',Icons.percent],
      ['مولد كلمات مرور','أنشئ كلمة مرور قوية',Icons.password],
      ['مولد أرقام عشوائية','اختر رقمًا ضمن نطاق',Icons.casino],
      ['أيام الأسبوع','اعرف يوم أي تاريخ',Icons.today],
      ['بداية ونهاية السنة','عداد السنة الميلادية',Icons.event],
      ['أهداف الشهر','خطط لأهدافك الشهرية',Icons.flag],
      ['متتبع العادات','تابع عادة يومية',Icons.track_changes],
      ['قائمة المشتريات','رتب احتياجاتك',Icons.shopping_cart],
      ['حفظ رقم مهم','احتفظ بالأرقام محليًا',Icons.contact_phone],
      ['ملاحظات سريعة','اكتب واحفظ محليًا',Icons.sticky_note_2],
      ['اختبار معلومات','اختبر معلوماتك العامة',Icons.quiz],
      ['تحدي النقر','اختبر سرعتك',Icons.touch_app],
      ['لعبة تخمين الرقم','اكتشف الرقم المخفي',Icons.question_mark],
    ];
    return ListView(padding:const EdgeInsets.all(14),children:[
      const Text('أدواتك اليومية',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold,color:navy)),
      const SizedBox(height:4), const Text('أكثر من 25 أداة وفكرة في مكان واحد',style:TextStyle(color:Colors.black54)),
      const SizedBox(height:12),
      ...items.map((e)=>Card(color:Colors.white,elevation:0,child:ListTile(leading:CircleAvatar(backgroundColor:navy,child:Icon(e.icon,color:gold)),title:Text(e.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(e.desc),trailing:const Icon(Icons.chevron_left),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>e.page))))),
      const Padding(padding:EdgeInsets.symmetric(vertical:12),child:Text('أدوات إضافية ضمن خارطة التطوير',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18,color:navy))),
      ...extras.map((e)=>InfoTile(icon:e[2] as IconData,title:e[0] as String,subtitle:e[1] as String)),
    ]);
  }
}
class ToolItem { final String name,desc; final IconData icon; final Widget page; ToolItem(this.name,this.desc,this.icon,this.page); }

class DateConverterPage extends StatefulWidget { const DateConverterPage({super.key}); @override State<DateConverterPage> createState()=>_DateConverterPageState(); }
class _DateConverterPageState extends State<DateConverterPage>{
 DateTime selected=DateTime.now();
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('تحويل التاريخ')),body:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  const Text('اختر تاريخًا ميلاديًا',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),
  const SizedBox(height:12), ElevatedButton.icon(onPressed:()async{final d=await showDatePicker(context:context,initialDate:selected,firstDate:DateTime(1900),lastDate:DateTime(2100));if(d!=null)setState(()=>selected=d);},icon:const Icon(Icons.calendar_month),label:Text(gDate(selected))),
  const SizedBox(height:24),resultBox('الميلادي',gDate(selected)),const SizedBox(height:12),resultBox('الهجري',hDate(selected)),
  const SizedBox(height:20),const Text('ملاحظة: قد يختلف التاريخ الهجري يومًا حسب التقويم المعتمد في بلدك.',style:TextStyle(color:Colors.black54)),
 ])));
}
Widget resultBox(String title,String value)=>Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:navy,borderRadius:BorderRadius.circular(18)),child:Column(children:[Text(title,style:const TextStyle(color:Colors.white70)),const SizedBox(height:8),Text(value,style:const TextStyle(color:gold,fontSize:25,fontWeight:FontWeight.bold))]));

class AgePage extends StatefulWidget { const AgePage({super.key}); @override State<AgePage> createState()=>_AgePageState(); }
class _AgePageState extends State<AgePage>{DateTime? birth;String result='اختر تاريخ ميلادك';@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('حاسبة العمر')),body:Padding(padding:const EdgeInsets.all(20),child:Column(children:[ElevatedButton(onPressed:()async{final d=await showDatePicker(context:context,initialDate:DateTime(2000),firstDate:DateTime(1900),lastDate:DateTime.now());if(d!=null){birth=d;final n=DateTime.now();int y=n.year-d.year,m=n.month-d.month,days=n.day-d.day;if(days<0){m--;days+=DateTime(n.year,n.month,0).day;}if(m<0){y--;m+=12;}setState(()=>result='$y سنة و$m شهر و$days يوم');}},child:const Text('اختيار تاريخ الميلاد')),const SizedBox(height:25),Text(result,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:navy))])));
}

class DaysPage extends StatefulWidget {const DaysPage({super.key});@override State<DaysPage> createState()=>_DaysPageState();}
class _DaysPageState extends State<DaysPage>{DateTime a=DateTime.now(),b=DateTime.now().add(const Duration(days:30));@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('فرق الأيام')),body:Padding(padding:const EdgeInsets.all(18),child:Column(children:[dateButton(context,'التاريخ الأول',a,(d)=>setState(()=>a=d)),dateButton(context,'التاريخ الثاني',b,(d)=>setState(()=>b=d)),const SizedBox(height:25),Text('${b.difference(a).inDays.abs()} يوم',style:const TextStyle(fontSize:30,fontWeight:FontWeight.bold,color:navy))])));}
Widget dateButton(BuildContext c,String label,DateTime d,ValueChanged<DateTime> change)=>ListTile(title:Text(label),subtitle:Text(gDate(d)),trailing:const Icon(Icons.edit_calendar),onTap:()async{final x=await showDatePicker(context:c,initialDate:d,firstDate:DateTime(1900),lastDate:DateTime(2100));if(x!=null)change(x);});

class CountdownPage extends StatefulWidget{const CountdownPage({super.key});@override State<CountdownPage> createState()=>_CountdownPageState();}
class _CountdownPageState extends State<CountdownPage>{DateTime target=DateTime.now().add(const Duration(days:10));@override Widget build(BuildContext context){final days=target.difference(DateTime.now()).inDays;return Scaffold(appBar:AppBar(title:const Text('العد التنازلي')),body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text('باقي على ${gDate(target)}',style:const TextStyle(fontSize:18)),Text('$days',style:const TextStyle(fontSize:70,color:navy,fontWeight:FontWeight.bold)),const Text('يوم'),const SizedBox(height:20),ElevatedButton(onPressed:()async{final d=await showDatePicker(context:context,initialDate:target,firstDate:DateTime.now(),lastDate:DateTime(2100));if(d!=null)setState(()=>target=d);},child:const Text('تغيير المناسبة'))])));}}

class AddDurationPage extends StatefulWidget{const AddDurationPage({super.key});@override State<AddDurationPage> createState()=>_AddDurationPageState();}
class _AddDurationPageState extends State<AddDurationPage>{DateTime date=DateTime.now();final ctl=TextEditingController(text:'7');String unit='أيام';@override Widget build(BuildContext context){final n=int.tryParse(ctl.text)??0;final out=unit=='أسابيع'?date.add(Duration(days:n*7)):unit=='أشهر'?DateTime(date.year,date.month+n,date.day):date.add(Duration(days:n));return Scaffold(appBar:AppBar(title:const Text('إضافة مدة لتاريخ')),body:Padding(padding:const EdgeInsets.all(18),child:Column(children:[dateButton(context,'التاريخ الأساسي',date,(d)=>setState(()=>date=d)),TextField(controller:ctl,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'العدد')),DropdownButton<String>(value:unit,items:['أيام','أسابيع','أشهر'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>unit=v!)),const SizedBox(height:25),Text(gDate(out),style:const TextStyle(fontSize:30,fontWeight:FontWeight.bold,color:navy))])));}}

class CalculatorPage extends StatefulWidget{const CalculatorPage({super.key});@override State<CalculatorPage> createState()=>_CalculatorPageState();}
class _CalculatorPageState extends State<CalculatorPage>{final a=TextEditingController(),b=TextEditingController();String op='+',answer='النتيجة';@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('الحاسبة')),body:Padding(padding:const EdgeInsets.all(20),child:Column(children:[TextField(controller:a,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'الرقم الأول')),DropdownButton(value:op,items:['+','−','×','÷'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>op=v!)),TextField(controller:b,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'الرقم الثاني')),const SizedBox(height:20),ElevatedButton(onPressed:(){final x=double.tryParse(a.text)??0,y=double.tryParse(b.text)??0;final r=op=='+'?x+y:op=='−'?x-y:op=='×'?x*y:y==0?double.nan:x/y;setState(()=>answer=r.isNaN?'لا يمكن القسمة على صفر':r.toString());},child:const Text('احسب')),Text(answer,style:const TextStyle(fontSize:25,color:navy,fontWeight:FontWeight.bold))])));}

class FocusPage extends StatefulWidget{const FocusPage({super.key});@override State<FocusPage> createState()=>_FocusPageState();}
class _FocusPageState extends State<FocusPage>{int seconds=60;Timer? timer;bool running=false;void start(){timer?.cancel();setState(()=>running=true);timer=Timer.periodic(const Duration(seconds:1),(t){if(seconds<=0){t.cancel();setState(()=>running=false);}else setState(()=>seconds--);});}@override void dispose(){timer?.cancel();super.dispose();}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('مؤقت التركيز')),body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text('$seconds ثانية',style:const TextStyle(fontSize:55,color:navy,fontWeight:FontWeight.bold)),ElevatedButton(onPressed:running?null:start,child:const Text('ابدأ')),TextButton(onPressed:(){timer?.cancel();setState((){seconds=60;running=false;});},child:const Text('إعادة'))])));}

class AboutCalendarPage extends StatelessWidget{const AboutCalendarPage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('عن التقويمين')),body:const Padding(padding:EdgeInsets.all(20),child:Text('التقويم الميلادي تقويم شمسي يعتمد على دورة الأرض حول الشمس. أما التقويم الهجري فهو تقويم قمري، وتتكون سنته من اثني عشر شهرًا قمريًا. قد يختلف اعتماد بداية الشهر الهجري بحسب رؤية الهلال والجهة الرسمية في كل بلد.',style:TextStyle(fontSize:18,height:1.8))));}

class NotesPage extends StatefulWidget{const NotesPage({super.key});@override State<NotesPage> createState()=>_NotesPageState();}
class _NotesPageState extends State<NotesPage>{final ctl=TextEditingController();String saved='';@override void initState(){super.initState();load();}Future<void> load()async{final p=await SharedPreferences.getInstance();setState(()=>saved=p.getString('note')??'');}Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('note',ctl.text);setState(()=>saved=ctl.text);FocusScope.of(context).unfocus();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ الملاحظة على الجهاز')));}@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Text('مفكرتي',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),TextField(controller:ctl,maxLines:5,decoration:const InputDecoration(hintText:'اكتب ملاحظتك هنا...',filled:true,fillColor:Colors.white,border:OutlineInputBorder())),const SizedBox(height:10),ElevatedButton(onPressed:save,child:const Text('حفظ الملاحظة')),const SizedBox(height:16),const Text('المحفوظ سابقًا',style:TextStyle(fontWeight:FontWeight.bold)),Expanded(child:SingleChildScrollView(child:Text(saved.isEmpty?'لا توجد ملاحظات محفوظة':saved,style:const TextStyle(fontSize:16))))]));}

class TasksPage extends StatefulWidget{const TasksPage({super.key});@override State<TasksPage> createState()=>_TasksPageState();}
class _TasksPageState extends State<TasksPage>{final c=TextEditingController();final List<String> tasks=[];@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('قائمة المهام')),body:Padding(padding:const EdgeInsets.all(16),child:Column(children:[Row(children:[Expanded(child:TextField(controller:c,decoration:const InputDecoration(hintText:'مهمة جديدة'))),IconButton(onPressed:(){if(c.text.trim().isNotEmpty)setState((){tasks.add(c.text.trim());c.clear();});},icon:const Icon(Icons.add_circle,color:navy))]),Expanded(child:ListView(children:tasks.asMap().entries.map((e)=>CheckboxListTile(value:false,onChanged:(_)=>setState(()=>tasks.removeAt(e.key)),title:Text(e.value))).toList()))])));}

class GamesPage extends StatelessWidget{const GamesPage({super.key});@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('استراحة ممتعة 🎮',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:12),gameCard(context,'اختبار المعلومات','أسئلة عامة سريعة',Icons.quiz,const QuizPage()),gameCard(context,'تحدي النقر','كم مرة تستطيع النقر خلال 10 ثوانٍ؟',Icons.touch_app,const TapGamePage()),gameCard(context,'خمن الرقم','اختر رقمًا من 1 إلى 20',Icons.question_mark,const GuessPage())]);}
Widget gameCard(BuildContext c,String title,String sub,IconData icon,Widget page)=>Card(color:Colors.white,elevation:0,child:ListTile(leading:Icon(icon,color:gold,size:30),title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(sub),trailing:const Icon(Icons.play_arrow),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>page))));

class QuizPage extends StatefulWidget{const QuizPage({super.key});@override State<QuizPage> createState()=>_QuizPageState();}
class _QuizPageState extends State<QuizPage>{int i=0,score=0;final qs=[['كم عدد أشهر السنة الميلادية؟',['10','12','14'],'12'],['ما الكوكب المعروف بالكوكب الأحمر؟',['الأرض','المريخ','زحل'],'المريخ'],['كم عدد أيام الأسبوع؟',['5','7','9'],'7'],['ما عاصمة اليمن؟',['صنعاء','عدن','تعز'],'صنعاء']];@override Widget build(BuildContext context){if(i>=qs.length)return Scaffold(appBar:AppBar(title:const Text('نتيجة الاختبار')),body:Center(child:Text('نتيجتك: $score من ${qs.length}',style:const TextStyle(fontSize:28,fontWeight:FontWeight.bold))));final q=qs[i];return Scaffold(appBar:AppBar(title:const Text('اختبار المعلومات')),body:Padding(padding:const EdgeInsets.all(20),child:Column(children:[Text('السؤال ${i+1} من ${qs.length}',style:const TextStyle(color:Colors.grey)),const SizedBox(height:30),Text(q[0] as String,style:const TextStyle(fontSize:23,fontWeight:FontWeight.bold)),const SizedBox(height:20),...(q[1] as List<String>).map((v)=>SizedBox(width:double.infinity,child:Padding(padding:const EdgeInsets.only(bottom:10),child:ElevatedButton(onPressed:(){setState((){if(v==q[2])score++;i++;});},child:Text(v)))))])));}}

class TapGamePage extends StatefulWidget{const TapGamePage({super.key});@override State<TapGamePage> createState()=>_TapGamePageState();}
class _TapGamePageState extends State<TapGamePage>{int count=0,left=10;Timer? t;bool started=false;void begin(){setState((){count=0;left=10;started=true;});t=Timer.periodic(const Duration(seconds:1),(x){if(left<=1){x.cancel();setState((){left=0;started=false;});}else setState(()=>left--);});}@override void dispose(){t?.cancel();super.dispose();}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('تحدي النقر')),body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text('الوقت: $left',style:const TextStyle(fontSize:25)),Text('$count',style:const TextStyle(fontSize:70,fontWeight:FontWeight.bold,color:navy)),ElevatedButton(onPressed:started?()=>setState(()=>count++):begin,child:Text(started?'انقر بسرعة!':'ابدأ التحدي'))])));}

class GuessPage extends StatefulWidget{const GuessPage({super.key});@override State<GuessPage> createState()=>_GuessPageState();}
class _GuessPageState extends State<GuessPage>{int target=Random().nextInt(20)+1;final c=TextEditingController();String msg='خمن رقمًا من 1 إلى 20';@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('خمن الرقم')),body:Padding(padding:const EdgeInsets.all(20),child:Column(children:[Text(msg,style:const TextStyle(fontSize:20)),TextField(controller:c,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'تخمينك')),ElevatedButton(onPressed:(){final n=int.tryParse(c.text);setState((){if(n==target){msg='أحسنت! إجابة صحيحة 🎉';}else if(n==null){msg='أدخل رقمًا صحيحًا';}else{msg=n<target?'أكبر من ذلك':'أصغر من ذلك';}});},child:const Text('تحقق')),TextButton(onPressed:(){setState((){target=Random().nextInt(20)+1;msg='رقم جديد! حاول مرة أخرى';c.clear();});},child:const Text('لعبة جديدة'))])));}